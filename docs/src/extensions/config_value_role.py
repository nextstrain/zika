"""
Sphinx extension providing a custom interpreted text role for reading YAML config values.

This extension adds a :configvalue:`file:key` role that reads values from YAML files
and inserts them into the documentation.
"""

import os
import yaml
from docutils import nodes
from docutils.parsers.rst import roles
from sphinx.application import Sphinx
from sphinx.util.docutils import ReferenceRole


class ConfigValueRole(ReferenceRole):
    """Custom role for reading values from YAML configuration files."""
    
    def __init__(self):
        super().__init__()
        self.name = 'configvalue'
    
    def run(self):
        """Process the role and return the appropriate node."""
        # Parse the target to extract file path and key
        target = self.target
        
        if ':' not in target:
            # If no colon, assume it's just a key in the default config
            config_file = "phylogenetic/defaults/config.yaml"
            key = target
        else:
            # Split on first colon to separate file path and key
            parts = target.split(':', 1)
            config_file = parts[0]
            key = parts[1]
        
        # Resolve the config file path relative to the project root
        project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
        config_path = os.path.join(project_root, config_file)
        
        try:
            # Read and parse the YAML file
            with open(config_path, 'r') as f:
                config_data = yaml.safe_load(f)
            
            # Navigate to the nested key using dot notation
            value = self._get_nested_value(config_data, key)
            
            if value is None:
                # Key not found
                return [nodes.literal(text=f"<config value '{key}' not found in {config_file}>")], []
            
            # Check if the value is a list or dictionary (complex data structure)
            if isinstance(value, (list, dict)):
                # Render as YAML code block
                yaml_content = yaml.dump(value, default_flow_style=False, indent=2)
                code_block = nodes.literal_block(text=yaml_content, language='yaml')
                return [code_block], []
            else:
                # Return simple values as inline literal text
                return [nodes.literal(text=str(value))], []
            
        except FileNotFoundError:
            return [nodes.literal(text=f"<config file '{config_file}' not found>")], []
        except yaml.YAMLError as e:
            return [nodes.literal(text=f"<error parsing config file '{config_file}': {e}>")], []
        except Exception as e:
            return [nodes.literal(text=f"<error reading config value '{key}' from '{config_file}': {e}>")], []
    
    def _get_nested_value(self, data, key):
        """Get a nested value from a dictionary using dot notation and array indexing."""
        if '.' in key or '[' in key:
            # Handle nested keys like "filter.group_by" or "inputs[0].metadata"
            current = data
            
            # Split by dots but preserve array indices
            parts = key.split('.')
            for part in parts:
                if '[' in part and ']' in part:
                    # Handle array indexing like "inputs[0]"
                    base_key = part[:part.index('[')]
                    index_str = part[part.index('[')+1:part.index(']')]
                    
                    if isinstance(current, dict) and base_key in current:
                        current = current[base_key]
                    else:
                        return None
                    
                    try:
                        index = int(index_str)
                        if isinstance(current, list) and 0 <= index < len(current):
                            current = current[index]
                        else:
                            return None
                    except (ValueError, TypeError):
                        return None
                else:
                    # Handle regular dictionary keys
                    if isinstance(current, dict) and part in current:
                        current = current[part]
                    else:
                        return None
            return current
        else:
            # Simple key lookup
            return data.get(key)


def setup(app: Sphinx):
    """Set up the Sphinx extension."""
    # Register the custom role
    roles.register_local_role('configvalue', ConfigValueRole())
    
    return {
        'version': '1.0',
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    } 