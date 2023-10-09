# Simple data definitions for Protection Domain and Resource

class ProtectionDomain(object):
    def __init__(self, name : str, resources=set(), resource_dir=set()):
        self.name : str = name
        self.resources = set()
        self.resources.update(resources)
        self.resource_dir : dict = resource_dir
    
    def __str__(self) -> str:
        return f"PD: {self.name}\n Resources: {self._stringify_resources()}\n"
    
    def add_resource(self,resource):
        self.resources.add(resource)
    
    def add_resources(self,resources):
        self.resources.update(resources)
    
    def get_resources(self):
        return self.resources
    
    def add_resource_dir(self, resource_dir):
        self.resource_dir = resource_dir

    def _stringify_resources(self) -> str:
        out = ""
        for resource in self.resources:
            out = out + f"{resource}, "
        return out


class Resource(object):
    def __init__(self, name : str, serving_PD=None, dependencies=set()):
        self.name : str = name
        self.dependencies = set()
        self.dependencies.update(dependencies)
        self.serving_PD = serving_PD

    def get_n_hop(self, n : int) -> set:
        n_hop_resources = {self}
        if n == 0:
            return n_hop_resources
        
        for resource in self.dependencies:
            n_hop_resources = n_hop_resources.union(resource.get_n_hop(n-1))
        
        if (n > 1) and (self.serving_PD is not None):
            for resource in self.serving_PD.resources:
                n_hop_resources.union(resource.get_n_hop(n-2))

        return n_hop_resources
    
    def add_dependency(self, dependency):
        self.dependencies.add(dependency)
    
    def __eq__(self, other : object) -> bool:
        if isinstance(other, Resource):
            return self.name == other.name
    
    def __str__(self) -> str:
        return f"{self.name}"

    def __hash__(self):
        return hash(self.name)

