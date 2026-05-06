#include <fcntl.h>
#include <unistd.h>

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;

    const char *path = "/var/mobile/Library/Logs/bitcrusher32-logoshook-marker.txt";
    const char *msg = "LogosLoggingTest marker: SpringBoard applicationDidFinishLaunching executed.\n";

    int fd = open(path, O_WRONLY | O_CREAT | O_APPEND, 0644);
    if (fd >= 0) {
        write(fd, msg, 75);
        close(fd);
    }
}

%end
