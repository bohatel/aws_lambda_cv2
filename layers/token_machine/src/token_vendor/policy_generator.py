from importlib.resources import files
from string import Template

from .exceptions import NotInitializedError


class PolicyGenerator:
    def __init__(self, tenant: str) -> None:
        self._templates: list[str] = []
        self._data = {
            'tenant': tenant
        }

    def addS3Folder(self, bucket: str) -> None:
        self._data['bucket'] = bucket
        self._templates.append('S3TenantFolder.json')

    def generate(self) -> str:
        if len(self._templates) == 0:
            raise NotInitializedError('No templates have been requested')

        statements: list[str] = []
        for template in self._templates:
            policy = files('token_vendor').joinpath(f'templates/{template}').read_text(encoding='UTF-8')
            statements.append(Template(policy).substitute(self._data))
        
        return f'{{ \"Version\": \"2012-10-17\",\n  \"Statement\": [\n{",".join(statements)}  ]\n}}'
