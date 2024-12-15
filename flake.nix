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
      base00 = "#041523";
      base01 = "#122339";
      base02 = "#003552";
      base03 = "#7a5759";
      base04 = "#6b6977";
      base05 = "#5b778c";
      base06 = "#333238";
      base07 = "#214d68";
      base08 = "#818591";
      base09 = "#9198a3";
      base0A = "#adb4b9";
      base0B = "#977d7c";
      base0C = "#977d7c";
      base0D = "#977d7c";
      base0E = "#9198a3";
      base0F = "#977d7c";
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

    darken = let
      darkenColor = color: percentage: let
        cleanColor = sanitizeColor color;
        rgb = nix-colors.lib.conversions.hexToRGB cleanColor;

        darken = c: let
          darkenedValue = c - (c * percentage);
        in
          builtins.floor darkenedValue;

        darkenedRgb = {
          r = darken (builtins.elemAt rgb 0);
          g = darken (builtins.elemAt rgb 1);
          b = darken (builtins.elemAt rgb 2);
        };
      in
        rgbToHex darkenedRgb.r darkenedRgb.g darkenedRgb.b;
    in
      darkenColor;

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
