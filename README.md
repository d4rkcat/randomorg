randomorg HTTPS Client
=========

Curl various formats of unique random strings from www.random.org using HTTPS, optional use of TOR proxy

	randomorg - HTTPS Client - Curl unique random strings from random.org using HTTPS for security

		Usage: randomorg -f <format> -l <length> <Options> [in any order]

		Required:
			-f  -  format:
				[an] mixed case alphanumerical
				[ln] lower case alphanumerical
				[un] upper case alphanumerical
				[a]  mixed case alphabetic
				[l]  lower case alphabetic
				[u]  upper case alphabetic
				[n]  numerical
				  				
			-l  -  length of string (characters)
		
		Optional:
			-n  -  number of strings
			-o  -  print output to file
			-t  -  use tor proxy (requires torify)
			-q  -  quiet, do not print remaining quota
			-p  -  post randomize with urandom
			-h  -  this help menu		
		Examples: 
			randomorg -f an -l 26	               	   ~ alphanumeric string, 26 characters
			randomorg -f a -l 14 -n 3 -t               ~ 3 alphabetic strings, 14 characters, use tor proxy
			randomorg -f n -l 8 -q -o Desktop/byte     ~ numerical string, 8 characters, quiet and output to file
