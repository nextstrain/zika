from docutils import nodes
from docutils.parsers.rst import Directive
import subprocess
import os

# Try to import SphinxDirective and SphinxError, fallback if not available for linter
try:
    from sphinx.util.docutils import SphinxDirective  # type: ignore
except ImportError:
    SphinxDirective = Directive
try:
    from sphinx.errors import SphinxError  # type: ignore
except ImportError:
    if 'SphinxError' not in globals():
        class SphinxError(Exception):
            pass
# Import the graphviz node
try:
    from sphinx.ext.graphviz import graphviz  # type: ignore
except ImportError:
    graphviz = None

class SnakemakeDagDirective(SphinxDirective):
    has_content = False
    required_arguments = 1  # workflow directory, e.g., 'ingest'
    optional_arguments = 0
    final_argument_whitespace = False

    def run(self):
        workflow_dir = self.arguments[0]
        project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../..'))
        workflow_path = os.path.join(project_root, workflow_dir)
        command = [
            'snakemake', '--cores', '1', '-npf', '--forceall', '--dag'
        ]
        try:
            # Run the command in the workflow directory
            proc = subprocess.run(
                command,
                cwd=workflow_path,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                check=True,
                text=True
            )
            # Filter out lines containing 'Building'
            dot_output = '\n'.join(
                line for line in proc.stdout.splitlines() if 'Building' not in line
            )
        except subprocess.CalledProcessError as e:
            raise SphinxError(f"Failed to generate Snakemake DAG for '{workflow_dir}': {e.stderr}")

        if graphviz is None:
            # Fallback: show as literal block if graphviz node is not available
            graphviz_node = nodes.literal_block(dot_output, dot_output)
            graphviz_node['language'] = 'dot'
            return [graphviz_node]
        # Return a graphviz node for rendering (correct usage)
        node = graphviz('', code=dot_output)
        node['options'] = {}
        return [node]

def setup(app):
    app.add_directive('snakemake-dag', SnakemakeDagDirective)
    return {
        'version': '0.1',
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    } 