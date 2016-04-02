#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <err.h>
#include <stdio.h>
#include <string.h>

int
main(void)
{
	struct addrinfo hints, *res;
	int r;

	memset(&hints, 0, sizeof(hints));
	hints.ai_socktype = SOCK_STREAM;

	if ((r = getaddrinfo("acme.com", "80", &hints, &res)) != 0)
			errx(1, "getaddrinfo: %s", gai_strerror(r));

	return 0;
}

