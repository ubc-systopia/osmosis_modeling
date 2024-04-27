include "model.dfy"

method example_test(){
    var resource_relation := ResourceRelation({});
    assert resource_relation == ResourceRelation({});
    var pd_0 := new ProtectionDomain({
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
    },{},{});
    var process_1 := new ProtectionDomain({VirtualResource("P1VAS")},{},{pd_0});
    var process_2 := new ProtectionDomain({VirtualResource("P2VAS")},{},{pd_0});


    assert pd_0.accessResource(PhysicalResource("Page16"));
    assert process_1.canAccessResource(PhysicalResource("Page16"));

    process_1.addResources({PhysicalResource("Page1"),PhysicalResource("Page2"),
        PhysicalResource("Page3"),PhysicalResource("Page4")});
    
    process_2.addResources({PhysicalResource("Page5"),PhysicalResource("Page6"),
        PhysicalResource("Page7"),PhysicalResource("Page8")});

    // Test that resource sets are disjoint
    assert (process_2.accesses - process_1.accesses) == process_2.accesses;
    assert (process_1.accesses - process_2.accesses) == process_1.accesses;

    assert !process_1.sharesResource(process_2);

    process_1.addResource(PhysicalResource("Page5"));

    assert process_1.sharesResource(process_2);
}