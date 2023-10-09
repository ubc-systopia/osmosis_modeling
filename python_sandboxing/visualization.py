from data_definitions import Resource, ProtectionDomain
from treelib import Node, Tree
from graphviz import Source
import subprocess

def draw_test():
    tree = Tree()

    tree.create_node("World","world")
    tree.create_node("North America", "n_america","world")
    tree.create_node("Europe", "europe", "world")
    tree.create_node("Asia", "asia", "world")
    tree.create_node("Vancouver", "vancouver", "n_america")

    tree.to_graphviz(filename="test.txt")
    s = Source.from_file(filename="test.txt",format='png')
    s.view()

def draw_PD_resource_tree(protection_domain : ProtectionDomain, suffix=""):
    resources_to_draw = list(protection_domain.resources)
    for resource in resources_to_draw:
        tree = Tree()
        filename = f"out/{protection_domain.name}_{resource.name}{suffix}.dot"
        tree.create_node(resource.name,resource.name) # root node
        draw_subresource(tree,resource)
        tree.to_graphviz(filename=filename)
        
def draw_subresource(tree : Tree, parent=None):
    resources = parent.get_n_hop(1).difference({parent})
    for resource in resources:
        tree.create_node(resource.name, resource.name, parent.name)
        draw_subresource(tree,resource)

def view_graph_from_file():
    # TODO: probably need to come up with a better way of doing this
    # For now this works
    beforefile = open("out/before.dot","+w")
    afterfile = open("out/after.dot","+w")
    subprocess.run(["m4", "merge_before_graphs.m4"],stdout=beforefile)
    subprocess.run(["m4", "merge_after_graphs.m4"],stdout=afterfile)
    s = Source.from_file(filename="out/before.dot",format='png')
    s.view()
    s = Source.from_file(filename="out/after.dot",format='png')
    s.view()
