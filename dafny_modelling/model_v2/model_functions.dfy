include "datatypes.dfy"

// PD Functions

function addResource(pd : ProtectionDomain, res : Resource) : ProtectionDomain {
    pd.(resources := pd.resources + {res})
}

function removeResource(pd : ProtectionDomain, res : Resource) : ProtectionDomain {
    pd.(resources := pd.resources - {res})
}

predicate hasResource(pd: ProtectionDomain, res : Resource) {
    hasResources(pd, {res})
}

predicate hasResources(pd: ProtectionDomain, res : set<Resource>) {
    res <= pd.resources
}

// NOTE: We want id in pd.handles as our trigger - TODO: Look up syntax and make change...
predicate canAccessResource(model : Model, pd : ProtectionDomain, res: Resource) 
    requires forall id {:trigger id in pd.handles} | id in pd.handles :: id in model.pds.Keys {
    exists id | id in pd.handles :: res in model.pds[id].resources
}

predicate sharesResource(pd1 : ProtectionDomain, pd2 : ProtectionDomain){
    exists resource | resource in pd1.resources :: resource in pd2.resources
}


ghost function getAllPDHandles(model : Model, ids: set<ID>) : (result : set<ProtectionDomain>)
    decreases ids
    requires forall id {:trigger id in model.pds.Keys} | id in ids :: id in model.pds.Keys
    ensures forall r | r in result :: true
{
    if ids == {} then {}
    else
        var id :| id in ids; 
        getAllPDHandles(model, ids - {id}) +  {model.pds[id]}
}

ghost function getAllAccessibleResources(model : Model, ids: set<ID>) : set<Resource>
    requires forall id {:trigger id in model.pds.Keys} | id in ids :: id in model.pds.Keys
{
    getResourcesOfPDs(getAllPDHandles(model,ids))
}

ghost function getResourcesOfPDs(pds : set<ProtectionDomain>) : set<Resource> 
    decreases pds {
    if 
        pds == {} then {} 
    else
        var pd :| pd in pds;
        pd.resources + getResourcesOfPDs(pds - {pd})
}

ghost predicate isEqual(model: Model, pd1:ProtectionDomain, pd2:ProtectionDomain) 
    requires forall id | id in (pd1.handles + pd2.handles) :: id in model.pds.Keys {
    var pd1_resources := getAllAccessibleResources(model, pd1.handles);
    var pd2_resources := getAllAccessibleResources(model, pd2.handles);
    (pd1_resources <= pd2_resources) || (pd2_resources <= pd1_resources)
}

// Resource Functions
function addResourceRelation(model : Model, relation : ResourceRelation) : Model {
    model.(resource_relations := model.resource_relations + {relation})
} 

function removeResourceRelation(model : Model, relation : ResourceRelation) : Model {
    model.(resource_relations := model.resource_relations - {relation})
}

ghost function PickResource(s: set<Resource>): Resource
  requires s != {}
{
  var x :| x in s; x
}

ghost predicate equalResources(resources1 : set<Resource>, resources2 : set<Resource>) 
    decreases resources1, resources2
{
    if resources1 == {} && resources2 != {} then false
    else if resources2 == {} && resources1 != {} then false
    else if resources1 == {} && resources2 == {} then true
    else
        var r1 := PickResource(resources1);
        var r2 := PickResource(resources2);
        equalResources(resources1 - {r1}, resources2 - {r2})
}
