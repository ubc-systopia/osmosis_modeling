from data_definitions import Resource, ProtectionDomain
from visualization import draw_test, draw_PD_resource_tree, view_graph_from_file

def main():
    PD_0 = ProtectionDomain(name="kernel")
    PD_1 = ProtectionDomain(name="Process1")
    PD_2 = ProtectionDomain(name="Process2")
    pages : list = list()
    for i in range(0,32):
        pages.append(Resource(name=f"Page{i+1}",serving_PD=PD_0))
    cores : list = list()
    for i in range(0,2):
        cores.append(Resource(name=f"Core{i+1}",serving_PD=PD_0))
    # PD_0 Resources
    for page in pages:
        PD_0.add_resource(page)
    for core in cores:
        PD_0.add_resource(core)
    # PD_1 Resources
    code_one  = Resource(name="Code1",  dependencies={pages[0]})
    stack_one = Resource(name="Stack1", dependencies={pages[1]})
    heap_one  = Resource(name="Heap1",  dependencies={pages[2]})
    vas_one   = Resource(name="VAS1",   serving_PD=PD_1, dependencies={code_one, stack_one, heap_one})
    pcb_one   = Resource(name="PCB1",   serving_PD=PD_1, dependencies={cores[0]})
    PD_1.resources.update({vas_one, pcb_one})

    # PD_2 Resources
    code_two  = Resource(name="Code2",  dependencies={pages[3]})
    stack_two = Resource(name="Stack2", dependencies={pages[4]})
    heap_two  = Resource(name="Heap2",  dependencies={pages[5]})
    vas_two   = Resource(name="VAS2",   serving_PD=PD_2, dependencies={code_two, stack_two, heap_two})
    pcb_two   = Resource(name="PCB2",   serving_PD=PD_2, dependencies={cores[1]})
    PD_2.resources.update({vas_two, pcb_two})

    draw_PD_resource_tree(PD_1, "_before")
    draw_PD_resource_tree(PD_2, "_before")

    # PD_1 shares heap memory with PD_2
    heap_two.add_dependency(pages[2])
    # PD_1 Gets scheduled on core 1
    pcb_one.remove_dependency(cores[0])
    pcb_one.add_dependency(cores[1])
    draw_PD_resource_tree(PD_1, "_after")
    draw_PD_resource_tree(PD_2, "_after")
    view_graph_from_file() 


if __name__ == "__main__":
    main()