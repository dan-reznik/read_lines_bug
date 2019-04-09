# binary search
find_weird_row <- function(n0,n_min,n_max) {
  l_skip <- read_lines(fname,skip=n0,n_max=1)
  l_all <- all_lines[n0+1]
  l_eq <- l_skip==l_all
  print(n0)
  #browser()
  if(n0%in%c(n_min,n_max)) {
    print(sprintf("line %d with l_eq=%s",
                  n0,
                  l_eq%>%as.character()))
    n0
  } else {
    if (!l_eq)
      find_weird_row(as.integer((n0+n_min)/2),n_min,n0)
    else
      find_weird_row(as.integer((n0+n_max)/2),n0,n_max)
  }
}