// Copyright © 2023 University of British Columbia. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0 OR MIT


/// Protection Domain Identifier (PDId), a globally unique identifier for protection domains.
type PDId = nat

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Resources
////////////////////////////////////////////////////////////////////////////////////////////////////

/// The Resource
///
/// A resource is something tangible, either virtual or physical, that a protection unit can use.

datatype Resource =
  | Resource()


////////////////////////////////////////////////////////////////////////////////////////////////////
//  Protection Domains
////////////////////////////////////////////////////////////////////////////////////////////////////

/// The Protection Domain
///
/// A protection domain represents an entity that owns resources it can access
datatype ProtectionDomain = ProtectionDomain(resources: set<Resource>)

ghost predicate PD_wf(rel: ProtectionDomain) {
  true
}

ghost predicate PD_HasResource(pd: ProtectionDomain, res: Resource) {
  res in pd.resources
}

ghost predicate PD_HasResources(pd: ProtectionDomain, res: set<Resource>) {
  res <= pd.resources
}

ghost function PD_GiveResource(pd: ProtectionDomain, res: Resource) : ProtectionDomain {
  pd.(resources := pd.resources + {res})
}

ghost function PD_TakeResource(pd: ProtectionDomain, res: Resource) : ProtectionDomain {
  pd.(resources := pd.resources - {res})
}


////////////////////////////////////////////////////////////////////////////////////////////////////
//  Resource Relation
////////////////////////////////////////////////////////////////////////////////////////////////////


/// Resource Relation
///
/// The resource
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


////////////////////////////////////////////////////////////////////////////////////////////////////
//  Osmosis Model (State Machine State)
////////////////////////////////////////////////////////////////////////////////////////////////////


datatype OsmosisModel = OsmosisModel(protection_domains: map<PDId, ProtectionDomain>, resource_relation: ResourceRelation)


////////////////////////////////////////////////////////////////////////////////////////////////////
//  Invariant
////////////////////////////////////////////////////////////////////////////////////////////////////

ghost predicate Inv(s: OsmosisModel) {
  && (forall pd | pd in s.protection_domains.Values :: PD_wf(pd))
  && RR_wf(s.resource_relation)
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//  State Machine: Initialization
////////////////////////////////////////////////////////////////////////////////////////////////////

ghost predicate Init(s: OsmosisModel, resources: set<Resource>)
{
  && s.resource_relation == ResourceRelation({})
  && s.protection_domains == map[0 := ProtectionDomain(resources)]
}


////////////////////////////////////////////////////////////////////////////////////////////////////
//  Transitions
////////////////////////////////////////////////////////////////////////////////////////////////////


predicate CreateEmptyPd(s: OsmosisModel, s': OsmosisModel, pid: PDId)
{
  && pid !in s.protection_domains
  && s' == s.(protection_domains := s.protection_domains[pid := ProtectionDomain({})])
}

predicate CreateEmptyPD2(s: OsmosisModel, s': OsmosisModel, pid: PDId)
{
  && pid !in s.protection_domains
  && pid in s'.protection_domains
  && s'.protection_domains[pid] == ProtectionDomain({})
  && s.resource_relation == s'.resource_relation
  // && (forall p | p in s.protection_domains.Keys :: p in s'.protection_domains.Keys 
  //     && s'.protection_domains[p] == s.protection_domains[p])
  && s'.protection_domains == s.protection_domains[pid := ProtectionDomain({})]
  
}

lemma emptyEquals(s: OsmosisModel, s': OsmosisModel, pid: PDId)
  ensures CreateEmptyPd(s, s', pid) == CreateEmptyPD2(s,s',pid) {

}

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Inductiveness of Transition
////////////////////////////////////////////////////////////////////////////////////////////////////

lemma CreateEmptyPd_PreservesInv(s: OsmosisModel, s': OsmosisModel, pid: PDId)
  requires Inv(s)
  requires CreateEmptyPd(s, s', pid)
  ensures Inv(s')
{

}


////////////////////////////////////////////////////////////////////////////////////////////////////
//  Inductiveness Proof
////////////////////////////////////////////////////////////////////////////////////////////////////

datatype Step =
  | CreateEmptyPd_Step(rid: PDId)
  | Stutter_Step


ghost predicate NextStep(s: OsmosisModel, s': OsmosisModel, step: Step) {
  match step {
    case CreateEmptyPd_Step(pid: PDId) =>
        && CreateEmptyPd(s, s', pid)
    case Stutter_Step =>
        && s' == s
  }
}

lemma NextStep_PreservesInv(s: OsmosisModel, s': OsmosisModel, step: Step)
  requires Inv(s)
  requires NextStep(s, s',step)
  ensures Inv(s')
{
  match step {
    case CreateEmptyPd_Step(pid) => CreateEmptyPd_PreservesInv(s, s', pid);
    case Stutter_Step => { }
  }
}

ghost predicate Next(s: OsmosisModel, s': OsmosisModel) {
  exists step :: NextStep(s, s', step)
}

/// any transition satisfies the invariant
lemma Next_Implies_inv(s: OsmosisModel, s': OsmosisModel)
  requires Inv(s)
  requires Next(s, s')
  ensures Inv(s')
{
  var step :| NextStep(s, s', step);
  NextStep_PreservesInv(s, s', step);
}

/// the init step preserves the invariant
lemma Init_Implies_Inv(s: OsmosisModel, resources: set<Resource>)
  requires Init(s, resources)
  ensures Inv(s)
{ }
