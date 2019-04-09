Issue with readr::read\_lines()’ skip & n\_max
================
Dan S. Reznik
2019-04-08

``` r
suppressMessages(library(tidyverse))
```

Confirm UTF-8 encoding of included zip file (it contains a larger .txt)

``` r
fname <- "test_file.zip"
guess_encoding(fname)
```

    ## # A tibble: 4 x 2
    ##   encoding     confidence
    ##   <chr>             <dbl>
    ## 1 UTF-8              1   
    ## 2 Shift_JIS          1   
    ## 3 windows-1252       0.68
    ## 4 windows-1250       0.31

Read all lines in zip (approx. 31.6k)

``` r
all_lines <- read_lines(fname)
length(all_lines)
```

    ## [1] 31695

Notice all lines have “well-formed” terminations with a carriage-return
followed by a newline.

``` r
{
  s <- read_file(fname)
  print(s %>% str_count("\\r"))
  print(s %>% str_count("\\n"))
  print(s %>% str_count("\\r\\n"))
  print(s %>% str_count("\\n\\r"))
}
```

    ## [1] 31695
    ## [1] 31695
    ## [1] 31695
    ## [1] 0

For this file, the separator is “;” (irrelevant for read\_lines()), and
there should be 45 per line. However, notice a few lines have a
non-standard number of separators (‘;’), namely: 46 and 48.

``` r
all_lines %>%
  str_count(";") %>%
  table
```

    ## .
    ##    45    46    48 
    ## 31678    14     3

List which lines have the wrong number of separators, as this will drive
us to the bug.

``` r
all_lines %>%
  str_count(";") %>%
  {which(.!=45)}
```

    ##  [1] 14579 24268 24269 26000 26792 26793 27535 29736 29737 29738 29755
    ## [12] 29764 29936 29937 30383 30384 30385

Use `read_lines()` to read only the first lines with the wrong number of
separators, shown above to be line \# 14579. So “skip” that number of
lines minus one.

``` r
line1 <- read_lines(fname,
                    skip=14578,
                    n_max=1)
```

Notice its content not only has a different number of separators, it’s a
different line altogether\! (herein lies the bug)

``` r
all_lines[14579] %>% str_count(";")
```

    ## [1] 48

``` r
line1 %>% str_count(";")
```

    ## [1] 45

``` r
all_lines[14579] == line1
```

    ## [1] FALSE

Notice the line retrieved by `read_lines(skip=14578,n_max=1)` above
actually appears much later in the file, suggesting the reading under
this skip+n\_max mode lost “sync”.

``` r
(all_lines==line1)%>%which
```

    ## [1] 17923

Notes: \* this bug is not caused by the .zip (same behavior if starts
from an uncompressed file) \* this is not related to encoding, in fact,
I made sure the file inside the zip is UTF-8 \* this issue seems to
manifest itself with longer files only. potentially there’s a character
within this file being interpreted as a carriage return.
