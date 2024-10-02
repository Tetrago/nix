final: prev: {
  python3 = prev.python3.override {
    self = prev.python3;
    packageOverrides = _: prevPy: {
      angrop = prevPy.angrop.overridePythonAttrs (prevAttrs: {
        dependencies = final.lib.lists.remove prevPy.progressbar prevAttrs.dependencies;
      });
    };
  };
}
