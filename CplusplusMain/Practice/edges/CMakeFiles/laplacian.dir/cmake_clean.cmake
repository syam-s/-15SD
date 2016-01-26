file(REMOVE_RECURSE
  "laplacian.pdb"
  "laplacian"
)

# Per-language clean rules from dependency scanning.
foreach(lang)
  include(CMakeFiles/laplacian.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
