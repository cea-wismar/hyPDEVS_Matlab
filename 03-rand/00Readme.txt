Random number generators inherited from Matlab GPPS by T. Pawletta

All random number generators require a parameter 'genno', which 
sets a random stream number to obtain independent
random streams.

-------------
discrandd ...generation of discrete empirical distributed random numbers
          ...y=discrandd(genno,prob_tab)

contrandd ...generation of continuous empirical distributed random numbers
          ...y=contrandd(genno,prob_tab)

expod     ...generation of exponential distributed random numbers
          ...y=expod(genno,mue)

triangd   ...generation of triangular distributed random numbers
          ...y=triangd(genno,a,c,b)

cuniformd ...generation of continuous uniform numbers in [a,b]
          ...y=cuniformd(genno,a,b) 

duniformd ...generation of discrete uniform numbers in [a,b]
          ...y=duniformd(genno,a,b)

 
