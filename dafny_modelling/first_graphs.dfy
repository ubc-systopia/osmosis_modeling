
type ID = nat

datatype Resource = 
    | PhysicalResource()
    | VirtualResource()

datatype ProtectionDomain = ProtectionDomain(
    resources: set<Resource>,      // Black arrows
    manages:set<Resource>,         // Red arrows
    handles:set<ProtectionDomain>  // Blue arrows
)

ghost predicate PD_wf(rel: ProtectionDomain) {
    (rel.resources - rel.manages) == {}
}

ghost predicate PD_AccessesResource(pd: ProtectionDomain, res: Resource) {
    res in (pd.resources + pd.manages)
}

ghost predicate PD_ManagesResource(pd: ProtectionDomain, res: Resource) {
    res in pd.manages
}

ghost predicate PD_AccessesResources(pd: ProtectionDomain, res: set<Resource>) {
    res <= (pd.resources + pd.manages)
}

ghost predicate PD_ManagesResources(pd: ProtectionDomain, res: set<Resource>) {
    res <= pd.manages
}

ghost predicate PD_Can_AccessResource(pd: ProtectionDomain, res: Resource) {
    exists some_pd :: some_pd in pd.handles && PD_ManagesResource(some_pd,res) 
}
