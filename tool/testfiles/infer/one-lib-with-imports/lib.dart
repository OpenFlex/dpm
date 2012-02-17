#library("my-lib-with-dependencies");

#import('dpm:my:dependency1:1.0');
#import("dpm:dependency2:1.0");
#import('dpm:dependency3');
#import("dpm:my:dependency4");

test() => print('test');

