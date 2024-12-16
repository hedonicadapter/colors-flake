{
  description = "Global color settings and utils";

  inputs = {
    nix-colors = {url = "github:misterio77/nix-colors";};
  };

  outputs = {
    nixpkgs,
    nix-colors,
    ...
  }: let
    colors = {
      base00 = "#000000";
      base01 = "#0c0c0c";
      base02 = "#131313";
      base03 = "#262626";
      base04 = "#504d47";
      base05 = "#f5dcbc";
      base06 = "#ffbb00";
      base07 = "#ffebd1";
      base08 = "#eb1b00";
      base09 = "#ffbb00";
      base0A = "#ffd45e";
      base0B = "#00a824";
      base0C = "#0bc2a3";
      base0D = "#d857ad";
      base0E = "#d31353";
      base0F = "#ffbb00";
    };

    sanitizeColor = color:
      if builtins.substring 0 1 color == "#"
      then builtins.substring 1 (builtins.stringLength color - 1) color
      else color;

    rgbToHex = r: g: b: let
      toHex = x: let
        hex = nixpkgs.lib.toHexString (builtins.floor x);
      in
        if builtins.stringLength hex == 1
        then "0${hex}"
        else hex;
    in "#${toHex r}${toHex g}${toHex b}";

    darken = color: percentage: let
      cleanColor = sanitizeColor color;
      rgb = nix-colors.lib.conversions.hexToRGB cleanColor;
      darken = c: let
        darkenedValue = c * (1 - percentage);
      in
        builtins.floor (
          if darkenedValue < 0
          then 0
          else if darkenedValue > 255
          then 255
          else darkenedValue
        );
      darkenedRgb = {
        r = darken (builtins.elemAt rgb 0);
        g = darken (builtins.elemAt rgb 1);
        b = darken (builtins.elemAt rgb 2);
      };
    in
      rgbToHex darkenedRgb.r darkenedRgb.g darkenedRgb.b;

    transparentize = let
      addAlpha = color: alpha: let
        alphaInt = builtins.floor (alpha * 255);
        alphaHex = builtins.substring 0 2 (builtins.toString (100 + alphaInt));

        cleanColor = sanitizeColor color;
        rgb = nix-colors.lib.conversions.hexToRGB cleanColor;
      in
        (rgbToHex (builtins.elemAt rgb 0) (builtins.elemAt rgb 1) (builtins.elemAt rgb 2)) + alphaHex;
    in
      addAlpha;

    isOpaque = color:
      builtins.stringLength color == 7 && builtins.substring 0 1 color == "#";

    colors_opaque = builtins.listToAttrs (
      builtins.filter (x: isOpaque (builtins.getAttr x.name colors))
      (builtins.map (name: {
          inherit name;
          value = builtins.getAttr name colors;
        })
        (builtins.attrNames colors))
    );

    colorNames = builtins.attrNames colors;
    cssColorVariables = builtins.concatStringsSep "\n" (
      builtins.map (color: "--color-${color}: ${colors.${color}};") colorNames
    );
  in {
    colors = colors;
    transparentize = transparentize;
    darken = darken;
    colors_opaque = colors_opaque;
    cssColorVariables = cssColorVariables;
  };
}
