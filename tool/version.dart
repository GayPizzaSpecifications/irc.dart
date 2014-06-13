part of hop_runner;

Task createVersionTask() {
    return new Task((TaskContext ctx) {
        var file = new File("pubspec.yaml");
        if (ctx.arguments.rest.length != 1) {
            ctx.severe("usage: ./build version <version>");
            return;
        }
        return new Future(() {
            var content = file.readAsStringSync();
            var pubspec = loadYaml(content);
            var old = pubspec["version"];
            content = content.replaceAll(old, ctx.arguments.rest[0]);
            file.writeAsStringSync(content);
        });
    });
}
