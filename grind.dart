import 'package:grinder/grinder.dart';

void main([List<String> args]) {
    defineTask('init', taskFunction: init);
    defineTask('analyze', taskFunction: analyze, depends: ['init']);
    defineTask('format', taskFunction: format, depends: ['init']);

    startGrinder(args);
}

void init(GrinderContext context) {
    PubTools pub = new PubTools();
    pub.get(context);
}

void analyze(GrinderContext context) {
    print("Analyzing Library");
    runSdkBinary(context, 'dartanalyzer', arguments: ['lib/irc.dart']);
    print("Analyzing Grind Script");
    runSdkBinary(context, 'dartanalyzer', arguments: ['grind.dart']);
}

void format(GrinderContext context) {
    print("Formatting Library");
    runSdkBinary(context, 'dartfmt', arguments: ['-w', '-t', 'lib/']);
    print("Formatting Grind Script");
    runSdkBinary(context, 'dartfmt', arguments: ['-w', '-t', 'grind.dart']);
}
