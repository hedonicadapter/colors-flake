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
      base00 = "#DBDBDB";
      base01 = "#E4E4E4";
      base02 = "#C0C0C0";
      base03 = "#4E4E4E";
      base04 = "#1C1C1C";
      base05 = "#232323";
      base06 = "#232323";
      base07 = "#1C1C1C";
      base08 = "#CC5450";
      base09 = "#A64270";
      base0A = "#307878";
      base0B = "#71983B";
      base0C = "#C57D42";
      base0D = "#376388";
      base0E = "#D7AB54";
      base0F = "#6D6D6D";
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
