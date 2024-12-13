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
      base00 = "#E3EFEF";
      base01 = "#C9DBDC";
      base02 = "#B0C5C8";
      base03 = "#98AFB5";
      base04 = "#8299A1";
      base05 = "#6D828E";
      base06 = "#5A6D7A";
      base07 = "#485867";
      base08 = "#b38686";
      base09 = "#d8bba2";
      base0A = "#aab386";
      base0B = "#87b386";
      base0C = "#86b3b3";
      base0D = "#868cb3";
      base0E = "#b386b2";
      base0F = "#b39f9f";
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
