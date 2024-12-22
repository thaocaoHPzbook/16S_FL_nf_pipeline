/*
===============================================================================

Nextflow pipeline using QIIME 2 to process CCS data via DADA2 plugin. Takes
in demultiplexed 16S amplicon sequencing FASTQ file with primers preserved.
(In the otherwords, the pipeline requires primer sequences to remain in the reads and not trimmed beforehand).

===============================================================================

Author: Thao Cao
Updated: 2024-12-22
*/

nextflow.enable.dsl=2

def helpMessage() {
  log.info"""
  Usage:
  This pipeline takes in the standard sample manifest and metadata file used in
  QIIME 2 and produces QC summary, taxonomy classification results and visualization.

  For samples TSV, two columns named "sample-id" and "absolute-filepath" are
  required. For metadata TSV file, at least two columns named "sample_id" and
  "condition" to separate samples into different groups.

  nextflow run main.nf --input manifest.tsv --metadata metadata.tsv \\
    --dada2_cpu 8 --vsearch_cpu 8

 By default, data will be proccessed in accordance with below paramters:
  --front_p    Forward primer sequence. Default to F27. (default: AGRGTTYGATYMTGGCTCAG)
  --adapter_p    Reverse primer sequence. Default to R1492. (default: AAGTCGTAACAAGGTARCY)
  --filterQ    Filter input reads above this Q value (default: 20).
  --downsample    Limit reads to a maximum of N reads if there are more than N reads (default: off)
  --max_ee    DADA2 max_EE parameter. Reads with number of expected errors higher than
              this value will be discarded (default: 2)
  --minQ    DADA2 minQ parameter. Reads with any base lower than this score 
            will be removed (default: 0)
  --min_len    Minimum length of sequences to keep (default: 1000)
  --max_len    Maximum length of sequences to keep (default: 1600)
  --pooling_method    QIIME 2 pooling method for DADA2 denoise see QIIME 2 
                      documentation for more details (default: "pseudo", alternative: "independent") 
  --maxreject    max-reject parameter for VSEARCH taxonomy classification method in QIIME 2
                 (default: 100)
  --maxaccept    max-accept parameter for VSEARCH taxonomy classification method in QIIME 2
                 (default: 100)
  --min_asv_totalfreq    Total frequency of any ASV must be above this threshold
                         across all samples to be retained. Set this to 0 to disable filtering
                         (default 5)
  --min_asv_sample    ASV must exist in at least min_asv_sample to be retained. 
                      Set this to 0 to disable. (default 1)
  --vsearch_identity    Minimum identity to be considered as hit (default 0.97)
  --rarefaction_depth    Rarefaction curve "max-depth" parameter. By default the pipeline
                         automatically select a cut-off above the minimum of the denoised 
                         reads for >80% of the samples. This cut-off is stored in a file called
                         "rarefaction_depth_suggested.txt" file in the results folder
                         (default: null)
  --dada2_cpu    Number of threads for DADA2 denoising (default: 8)
  --vsearch_cpu    Number of threads for VSEARCH taxonomy classification (default: 8)
  --outdir    Output directory name (default: "results")
  --vsearch_db	Location of VSEARCH database (e.g. silva-138-99-seqs.qza can be
                downloaded from QIIME database)
  --vsearch_tax    Location of VSEARCH database taxonomy (e.g. silva-138-99-tax.qza can be
                   downloaded from QIIME database)
  --silva_db   Location of Silva 138 database for taxonomy classification 
  --gtdb_db    Location of GTDB r202 for taxonomy classification
  --refseq_db  Location of RefSeq+RDP database for taxonomy classification
  --skip_nb    Skip Naive-Bayes classification (only uses VSEARCH) (default: false)
  --colorby    Columns in metadata TSV file to use for coloring the MDS plot
               in HTML report (default: condition)
  --run_picrust2    Run PICRUSt2 pipeline. Note that pathway inference with 16S using PICRUSt2
                    has not been tested systematically (default: false)
  --download_db    Download databases needed for taxonomy classification only. Will not
                   run the pipeline. Databases will be downloaded to a folder "databases"
                   in the Nextflow pipeline directory.
  --publish_dir_mode    Outputs mode based on Nextflow "publishDir" directive. Specify "copy"
                        if requires hard copies. (default: symlink)
  --version    Output version
  """
}
