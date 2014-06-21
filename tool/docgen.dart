part of hop_runner;

Task createDocGenTask(String path, {compile: false, Iterable<String> excludes: null, include_sdk: true, include_deps: false, out_dir: "docs", verbose: false}) {
  return new Task((TaskContext context) {
    var args = [];

    if (verbose) {
      args.add("--verbose");
    }

    if (excludes != null) {
      for (String exclude in excludes) {
        context.fine("Excluding Library: ${exclude}");
        args.add("--exclude-lib=${exclude}");
      }
    }

    if (compile) {
      args.add("--compile");
    }

    if (include_sdk) {
      args.add("--include-sdk");
    } else {
      args.add("--no-include-sdk");
    }

    if (include_deps) {
      args.add("--include-dependent-packages");
    } else {
      args.add("--no-include-dependent-packages");
    }

    args.add("--out=${out_dir}");

    args.addAll(context.arguments.rest);

    args.add(path);

    context.fine("using argments: ${args}");

    return Process.start("docgen", args).then((process) {
      return inheritIO(process);
    }).then((code) {
      if (code != 0) {
        context.fail("docgen exited with the status code ${code}");
      }
    });
  }, description: "Generates Documentation");
}
