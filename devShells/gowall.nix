{
  gowall,
  mkShell,
  vulkan-loader,
}:

mkShell {
  name = "gowall";

  buildInputs = [
    vulkan-loader
  ];

  packages = [
    gowall
  ];
}
