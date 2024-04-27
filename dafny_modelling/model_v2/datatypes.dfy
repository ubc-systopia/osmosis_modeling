// Datatypes
type ID = nat

datatype Resource = 
    | PhysicalResource(name: string) 
    | VirtualResource(name: string)

datatype ProtectionDomain = ProtectionDomain(
    resources:set<Resource>, 
    handles:set<ID>
)

datatype ResourceRelation = ResourceRelation(
    resource : Resource, 
    dependency : Resource
)

datatype Model = Model(
    pds : map<ID, ProtectionDomain>,
    resource_relations : set<ResourceRelation>
)