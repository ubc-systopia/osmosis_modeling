include "datatypes.dfy"

ghost function Pick(s: set<ResourceRelation>): ResourceRelation
  requires s != {}
{
  var x :| x in s; x
}

ghost function getAllRelationsWithResource(res : Resource, relation_set : set<ResourceRelation>) : (result : set<ResourceRelation>)
    decreases relation_set
    ensures forall rr | rr in relation_set :: (rr.resource == res ==> rr in result)
    ensures result <= relation_set
    ensures forall rr | rr in result :: rr.resource == res
{
    if relation_set == {} then {}
    else 
        var rr := Pick(relation_set);
        var remaining_set := relation_set - {rr};
        if res == rr.resource then 
            {rr} + getAllRelationsWithResource(res, remaining_set)
        else getAllRelationsWithResource(res, remaining_set)
}

lemma findsResources(res : Resource, relation_set : set<ResourceRelation>, result : set<ResourceRelation>)
    decreases relation_set
    requires result == getAllRelationsWithResource(res,relation_set) 
    ensures forall rr | rr in relation_set :: (rr.resource == res ==> rr in result)
    ensures result <= relation_set
    ensures forall rr | rr in result :: rr.resource == res
{
    if relation_set != {} {
        var rr := Pick(relation_set);
        var remaining_set := relation_set - {rr};
        var new_result := getAllRelationsWithResource(res,remaining_set);
        findsResources(res,remaining_set, new_result);        
    }
}


predicate Path(V :set<Resource>,E:set<ResourceRelation>, src: Resource, dst: Resource, path: seq<Resource>)
{
    |path| > 0 && path[0] == src && path[|path| - 1] == dst && (forall i :: 0 <= i < |path|-1 ==> path[i] in V && ResourceRelation(path[i],path[i+1]) in E)
}