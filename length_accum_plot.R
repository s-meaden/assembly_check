#install.packages(c("dplyr", "readr", "ggplot2"), repos = 
"https://www.stats.bris.ac.uk/R/")
library(dplyr)
library(readr)
library(ggplot2)

# Read command line arguments
args <- commandArgs(TRUE)
input_files <- args[1:(length(args) - 1)]  # Exclude the last argument, 
which is the output file path
output_file <- args[length(args)]

# Read data from input files
dfs <- lapply(input_files, function(filename) {
    df <- read_tsv(filename, col_names = c("contig_name", "length"), id = 
"filename") %>%
        mutate(sample_name = gsub("_contig_lengths.txt", "", filename)) 
%>%
        mutate(sample_name = gsub("./", "", sample_name)) %>%
        select(-filename)
    return(df)
})

# Combine data frames into a single data frame
combined_df <- do.call(rbind, dfs)

# Plot accumulation curve:

options(scipen=10000)
palette<-c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", 
"#0072B2", "#D55E00", "#CC79A7")

curve_plot<-combined_df %>%
  dplyr::group_by(sample_name) %>%
  dplyr::arrange( sample_name, -length) %>%
  dplyr::mutate( contig_order = 1:length(contig_name)) %>%
  dplyr::mutate( cumsum = cumsum(length)) %>%
  ggplot( ., aes(contig_order, cumsum))+
  geom_line( aes(color = sample_name))+
  theme_classic()+
  theme( text = element_text(size = 15))+
  xlab("Contig Number")+
  ylab("Cumulative Length")+
  scale_color_manual( values = palette)


# Save plot:
# Save plot:
print( paste("Saving plot as:", output_file))
ggsave(plot = curve_plot, filename =  output_file, width = 5, height = 5)
