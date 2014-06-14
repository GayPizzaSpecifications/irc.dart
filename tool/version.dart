part of hop_runner;

Task createVersionTask() {
    return new Task((TaskContext ctx) {
        var file = new File("pubspec.yaml");
        return new Future(() {
            var content = file.readAsStringSync();
            var pubspec = loadYaml(content);
            var old = pubspec["version"];

            var next = null;
            
            if (ctx.arguments.rest.length != 1) {
                next = guessNextVersion(old);
            } else {
                next = ctx.arguments.rest[0];
            }

            content = content.replaceAll(old, next);
            file.writeAsStringSync(content);
            ctx.info("Updated Version: v${old} => v${next}");
        });
    });
}

String guessNextVersion(String old) {
    if (old.contains("dev")) {
        String dev = old.substring(0, old.lastIndexOf("."));
        int devNumber = int.parse(old.substring(old.lastIndexOf(".") + 1));
        devNumber++;
        return dev + "." + devNumber.toString();
    } else {
        return incrementVersion(old);
    }
}

String incrementVersion(String old) {
    List<String> split = old.split(".");
    int major = int.parse(split[0]);
    int minor = int.parse(split[1]);
    int bugfix = int.parse(split[2]);
    if (bugfix == 9) {
        bugfix = 0;
        minor++;
    } else {
        bugfix++;
    }
    return "${major}.${minor}.${bugfix}";
}