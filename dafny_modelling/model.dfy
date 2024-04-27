// Copyright © 2023 University of British Columbia. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0 OR MIT

datatype Resource = PhysicalResource(name:string) | VirtualResource(name: string)

// Make a PD data type
// interp function Class -> data type
    // State of class before is X, state of class after is Y
    // effects of functions in the class are same as spec func on data type
// No dangling resource invariant!
 
class ProtectionDomain {
    var manages : set<Resource>
    var accesses : set<Resource>
    var handles : set<ProtectionDomain>

    constructor(manages : set<Resource>,accesses : set<Resource>, handles : set<ProtectionDomain>)
        ensures forall m | m in manages :: m in this.manages
        ensures forall a | a in manages :: a in this.manages {
        this.manages := manages;
        this.accesses := accesses;
        this.handles := handles;
    }

    ghost predicate wf() 
        reads this {
        accesses - manages == {}
    }

    ghost predicate accessResource(res: Resource) 
        reads this {
        res in (accesses + manages)
    }

    ghost predicate managesResource(res: Resource)
        reads this {
        res in manages
    }

    ghost predicate canAccessResource(res: Resource)
        reads this
        reads handles {
        exists some_pd | some_pd in handles :: some_pd.accessResource(res)
    }

    // we might need an ensures clause to make the resource visible
    method addResource(res: Resource)
        modifies this {
        this.accesses := this.accesses + {res};
    }

    method addResources(res: set<Resource>)
        modifies this {
        this.accesses := accesses + res;
    }

    method removeResource(res: Resource)
        modifies this {
        this.accesses := accesses - {res};
    }

    method removeResources(res: set<Resource>)
        modifies this {
        this.accesses := accesses - res;
    }

    // For now I will say "equal" means access to the same resources. If pd1 is a subset/superset of pd2,
    // then they are "equal"
    ghost predicate isEqual(pd:ProtectionDomain) 
        reads this
        reads pd{
        (accesses <= pd.accesses) || (pd.accesses <= accesses)
    }

    // TODO need a better name for this
    ghost predicate isLooselyEqual(pd:ProtectionDomain)
        reads this
        reads this.handles
        reads pd
        reads pd.handles {
        // If for every resource I can access, the other pd can too, then we are "equal"
        forall resource :: canAccessResource(resource) ==> pd.canAccessResource(resource)
    }
    
    //TODO: difference between making this a method and predicate is currently unclear
    ghost predicate sharesResource(pd:ProtectionDomain) 
        reads this 
        reads pd {
        exists some_resource :: (accessResource(some_resource) && pd.accessResource(some_resource))
    }

    ghost predicate canShareResource(pd:ProtectionDomain)
        reads this
        reads handles
        reads pd
        reads pd.handles {
        exists some_resource :: (canAccessResource(some_resource) && pd.canAccessResource(some_resource))
    }
}

ghost function addResourceFn(pd : ProtectionDomain, res: Resource) : ProtectionDomain
    reads pd {
    pd.accesses := pd.accesses + {res}
}

datatype ResourceRelation = ResourceRelation(rel: set<(Resource,Resource)>)

ghost predicate RR_wf(rr: ResourceRelation) {
  true
}

ghost function RR_AddRelation(rr: ResourceRelation, src: Resource, dst: Resource) : ResourceRelation
{
  rr.(rel := rr.rel + {(src, dst)})
}

ghost function RR_RemoveRelation(rr: ResourceRelation, src: Resource, dst: Resource) : ResourceRelation
{
  rr.(rel := rr.rel - {(src, dst)})
}