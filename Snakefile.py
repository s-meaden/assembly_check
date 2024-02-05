configfile: "config.yaml"

rule all:
    input:
        "contig_length_accumulation_curve.pdf"

rule count_contig_lengths:
    input:
        "input_sequences/{sample}.fasta"
    output:
        "contig_lengths/{sample}_contig_lengths.txt"
    shell:
        """
        python seq_length_counter.py {input[0]} > {output[0]}
        """


rule plot_contigs:
    input:
        expand("contig_lengths/{sample}_contig_lengths.txt",  sample=config["samples"])
    output:
        "contig_length_accumulation_curve.pdf"
    shell:
        """
        Rscript length_accum_plot.R {input} {output}
        """
