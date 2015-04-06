# Function to copy manuscript.Rmd from vignette into submission
copy<-function(file){
  file.copy(file,"manuscript.Rmd",overwrite=TRUE)
  #system("cp ../manuscript.Rmd .")
  system("cp -r ../components .")
}

render_doc<-function(file){
  rmarkdown::render(file,output_file = "manuscript.docx", output_format = "all")
}