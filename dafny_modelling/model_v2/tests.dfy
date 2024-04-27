include "datatypes.dfy"
include "model_functions.dfy"
include "cycle_checking.dfy"

method example_test(){
    var pd_0 := ProtectionDomain({
                    PhysicalResource("Page1"),PhysicalResource("Page2"),
                    PhysicalResource("Page3"),PhysicalResource("Page4"),
                    PhysicalResource("Page5"),PhysicalResource("Page6"),
                    PhysicalResource("Page7"),PhysicalResource("Page8"),
                    PhysicalResource("Page9"),PhysicalResource("Page10"),
                    PhysicalResource("Page11"),PhysicalResource("Page12"),
                    PhysicalResource("Page13"),PhysicalResource("Page14"),
                    PhysicalResource("Page15"),PhysicalResource("Page16"),
                    VirtualResource("KernelVAS"), VirtualResource("FreeList"),
                    VirtualResource("VASMetadata")
                },{});
    
    var process_1 := ProtectionDomain({VirtualResource("P1VAS")},{0});
    var process_2 := ProtectionDomain({VirtualResource("P2VAS")},{0});
    var model := Model(map[0 := pd_0, 1 := process_1, 2:= process_2],{});

    assert (canAccessResource(model,process_1,PhysicalResource("Page1")));
    assert (canAccessResource(model,process_2,PhysicalResource("Page1")));
    assert (!sharesResource(process_1,process_2));

    process_1 := addResource(process_1,PhysicalResource("Page1"));
    process_2 := addResource(process_2,PhysicalResource("Page1"));

    assert(sharesResource(process_1,process_2));
    var equal := isEqual(model,process_1,process_2);

    // Struggling to reason about more complex things
    // assert(!equal);

    var process_1_resources := getAllAccessibleResources(model, process_1.handles);
    ghost var set1 := {0};
    var set2 := {0};
    assert(set1 == set2);

    // print getAllPDHandles(model,{1},{});

    // assert(getAllPDHandles(model,{1}) == {pd_0});

    assert(getAllAccessibleResources(model,pd_0.handles) == pd_0.resources);

    assert(process_1_resources ==  {
                    PhysicalResource("Page1"),PhysicalResource("Page2"),
                    PhysicalResource("Page3"),PhysicalResource("Page4"),
                    PhysicalResource("Page5"),PhysicalResource("Page6"),
                    PhysicalResource("Page7"),PhysicalResource("Page8"),
                    PhysicalResource("Page9"),PhysicalResource("Page10"),
                    PhysicalResource("Page11"),PhysicalResource("Page12"),
                    PhysicalResource("Page13"),PhysicalResource("Page14"),
                    PhysicalResource("Page15"),PhysicalResource("Page16"),
                    VirtualResource("KernelVAS"), VirtualResource("FreeList"),
                    VirtualResource("VASMetadata"), VirtualResource("P1VAS")
                });

}

method resource_equality_test(){
    assert(equalResources({PhysicalResource("Page1"), VirtualResource("VAS")},{PhysicalResource("Page1"), VirtualResource("VAS")}));
}

method rr_test(){
    var r1 := VirtualResource("1");
    var r2 := PhysicalResource("2");
    var r3 := PhysicalResource("3");
    var r4 := VirtualResource("4");
    var rrA := ResourceRelation(r1,r2);
    var rrB := ResourceRelation(r1,r3);
    var rrC := ResourceRelation(r4,r2);
    var relation_set := {rrA,rrB,rrC};

    var ans1 := getAllRelationsWithResource(r1,{rrA,rrB,rrC});
    var ans := getAllRelationsWithResource(r4,{rrA,rrB,rrC});

    // findsResources(r4,relation_set,ans);
    // findsResources(r1,relation_set,ans1);
    
    assert(rrC.resource == r4);
    assert(ans1 == {rrA,rrB});
    assert(rrC in ans) by {findsResources(r4,relation_set,ans);}
    assert(ans == {rrC}) by {findsResources(r4,relation_set,ans);}
}

method path_test()
{
    var r1 := VirtualResource("1");
    var r2 := VirtualResource("2");
    var r3 := VirtualResource("3");
    var r4 := VirtualResource("4");
    var resources := {r1,r2,r3,r4};
    var resource_relations := {ResourceRelation(r1,r2), ResourceRelation(r2,r3), ResourceRelation(r1,r4)};
    assert(Path(resources,resource_relations,r1,r2,[r1,r2]));
    assert(Path(resources,resource_relations,r1,r3,[r1,r2,r3]));
}