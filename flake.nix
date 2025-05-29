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
    palette = {
      base00 = "#171413";
      base01 = "#2b2420";
      base02 = "#382f29";
      base03 = "#593e2e";
      base04 = "#967b6b";
      base05 = "#d1b5a5";
      base06 = "#e3d2c8";
      base07 = "#ebdfd8";
      base08 = "#94001b";
      base09 = "#a86500";
      base0A = "#A87E00";
      base0B = "#277A00";
      base0C = "#247F94";
      base0D = "#13578E";
      base0E = "#790239";
      base0F = "#a83800";
    };

    sanitizeColor = color:
      if builtins.substring 0 1 color == "#"
      then builtins.substring 1 (builtins.stringLength color - 1) color
      else color;

    toHex = x: let
      hex = nixpkgs.lib.toHexString (builtins.floor x);
    in
      if builtins.stringLength hex == 1
      then "0${hex}"
      else hex;

    hexColorTo0xAARRGGBB = color: alpha: let
      cleanColor = sanitizeColor color;

      rr = builtins.substring 0 2 cleanColor;
      gg = builtins.substring 2 2 cleanColor;
      bb = builtins.substring 4 2 cleanColor;

      alphaInt = builtins.floor (alpha * 255);

      aa = toHex alphaInt;
    in "0x${aa}${rr}${gg}${bb}";

    rgbToHex = r: g: b: "#${toHex r}${toHex g}${toHex b}";

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

    palette_opaque = builtins.listToAttrs (
      builtins.filter (x: isOpaque (builtins.getAttr x.name palette))
      (builtins.map (name: {
          inherit name;
          value = builtins.getAttr name palette;
        })
        (builtins.attrNames palette))
    );

    colorNames = builtins.attrNames palette;
    cssColorVariables = builtins.concatStringsSep "\n" (
      builtins.map (color: "--color-${color}: ${palette.${color}};") colorNames
    );
  in {
    palette = palette;
    palette_opaque = palette_opaque;
    transparentize = transparentize;
    darken = darken;
    cssColorVariables = cssColorVariables;
    hexColorTo0xAARRGGBB = hexColorTo0xAARRGGBB;
  };
}
