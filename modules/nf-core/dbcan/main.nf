process DBCAN {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/dbcan:4.1.4--pyhdfd78af_1':
        'biocontainers/dbcan:4.1.4--pyhdfd78af_1' }"

    input:
    tuple val(meta), path(faa)

    output:
    tuple val(meta), path("dbsub.out"), emit: dbsub
    path "versions.yml"               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    run_dbcan \\
        $args \\
        ${faa} \\
        protein \\
        -out_dir ${prefix}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dbcan: \$(dbcan --help)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dbcan: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """
}
