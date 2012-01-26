# graph_id = 397
# results_location = "/ebs_home/dgaffney/SocialFlow-Twitter-Consumer/slave/tasks/../tmp_files/bb210ee4998aa47a2fed90d9c794664d8d3b3b3d/scratch_processes/results.csv"
# host = "127.0.0.1"
# user = "root"
# passwd = "beefaroni"
# db = "audience_comparison"
# port = 3300
import sys
from collections import Counter
import time
start = time.time()
import MySQLdb
import networkx as nx
from networkx import *
from pylab import *
import numpy
import csv
from numpy import *
iNew = []
iOld = []
def pageRankGenerator(
    At = [array((), int32)],
    numLinks = array((), int32),
    ln = array((), int32),
    alpha = 0.85,
    convergence = 0.01,
    checkSteps = 10
    ):
    N = len(At)
    M = ln.shape[0]
    iNew = ones((N,), float32) / N
    iOld = ones((N,), float32) / N
    done = False
    iterations = 0
    while not done:
        print iterations
        iterations = iterations+1
        iNew /= sum(iNew)
        for step in range(checkSteps):
            iOld, iNew = iNew, iOld
            oneIv = (1 - alpha) * sum(iOld) / N
            oneAv = 0.0
            if M > 0:
                oneAv = alpha * sum(iOld.take(ln, axis = 0)) / N
            ii = 0
            while ii < N:
                page = At[ii]
                h = 0
                if page.shape[0]:
                    h = alpha * dot(
                        iOld.take(page, axis = 0),
                        1. / numLinks.take(page, axis = 0)
                        )
                iNew[ii] = h + oneAv + oneIv
                ii += 1
        
        diff = iNew - iOld
        done = (sqrt(dot(diff, diff)) / N < convergence)
        
        yield iNew


def transposeLinkMatrix(
    outGoingLinks = [[]]
    ):
    nPages = len(outGoingLinks)
    incomingLinks = [[] for ii in range(nPages)]
    numLinks = zeros(nPages, int32)
    leafNodes = []
    
    for ii in range(nPages):
        if len(outGoingLinks[ii]) == 0:
            leafNodes.append(ii)
        else:
            numLinks[ii] = len(outGoingLinks[ii])
            for jj in outGoingLinks[ii]:
                incomingLinks[jj].append(ii)
    
    incomingLinks = [array(ii) for ii in incomingLinks]
    numLinks = array(numLinks)
    leafNodes = array(leafNodes)
    
    return incomingLinks, numLinks, leafNodes


def pageRank(
    linkMatrix = [[]],
    alpha = 0.85,
    convergence = 0.01,
    checkSteps = 10
        ):
    incomingLinks, numLinks, leafNodes = transposeLinkMatrix(linkMatrix)
    for gr in pageRankGenerator(incomingLinks, numLinks, leafNodes, alpha = alpha, convergence = convergence, checkSteps = checkSteps):
        final = gr
        return final

class Edge(object):
	def __init__(self, row=[]):
		if not row:
			self.id = 0
			self.start_node = ""
			self.end_node = ""
			self.time = 0
			self.edge_id = 0
			self.flagged = 0
			self.style = ""
			self.start_node_kind = ""
			self.end_node_kind = ""
			self.analysis_metadata_id = 0
			self.curation_id = 0
			self.graph_id = 0
			self.start_centrality = 0.0
			self.end_centrality = 0.0
			self.start_degree = 0
			self.end_degree = 0
		else:
			self.id = row[0]
			self.start_node = row[1]
			self.end_node = row[2]
			self.time = row[3]
			self.edge_id = row[4]
			self.flagged = row[5]
			self.style = row[6]
			self.start_node_kind = row[7]
			self.end_node_kind = row[8]
			self.analysis_metadata_id = row[9]
			self.curation_id = row[10]
			self.graph_id = row[11]
			self.start_centrality = row[12]
			self.end_centrality = row[13]
			self.start_degree = row[14]
			self.end_degree = row[15]

graph_id = int(sys.argv[1])
results_location = sys.argv[2]
host = sys.argv[3]
user = sys.argv[4]
passwd = sys.argv[5]
db = sys.argv[6]
port = int(sys.argv[7])
conn = MySQLdb.connect (host = host, user = user, passwd = passwd, db = db, port=port)
cursor = conn.cursor()
cursor.execute ("select * from edges where graph_id = %s", graph_id)
nodes = []
start_nodes = []
end_nodes = []
edges = []
count = 0
for edge in cursor.fetchall():
    print "count: %s", count
    count= count+1
    edge = Edge(edge)
    edges.append(edge)

cursor.execute("select start_node, start_node_kind from edges where graph_id = %s group by binary start_node, start_node_kind", graph_id)
for row in cursor.fetchall():
  node = {'term': row[0], 'kind': row[1]}
  start_nodes.append(node)
  nodes.append(node)

cursor.execute("select end_node, end_node_kind from edges where graph_id = %s group by binary end_node, end_node_kind", graph_id)
for row in cursor.fetchall():
  node = {'term': row[0], 'kind': row[1]}
  end_nodes.append(node)
  nodes.append(node)

listing = []
ct = 0
#code is extraordinarily slow in calculating this. The basic goal here is to end up with a two-dimensional array. 
#Each element's index corresponds to the ith node processed 
#(start_nodes and end_nodes, where the listing beyond the length of start nodes corresponds to the end_nodes index plus the length of the start node)
for node in start_nodes:
    print ct
    ct=ct+1
    this_index = start_nodes.index(node)
    this_listing = []
    #Here's the real room for improvement: I'm iterating through the edges many times to insert the list of indexes for nodes that 
    #are connected to a given node. In this network, all start nodes (screen names) connect outwardly to words or phrases, so the only ones we actually need to map
    #are the start nodes (words never link back to their account, start_nodes never connect to other start nodes). Either way, this seems absurdly inefficient.
    for edge in edges:
        if edge.start_node == node['term'] and edge.start_node_kind == node['kind']:
            this_listing.append(end_nodes.index({'term': edge.end_node, 'kind': edge.end_node_kind})+len(start_nodes)-1)
    listing.append(this_listing)

for node in end_nodes:
    listing.append([])

#at this point you'll have listing looking something like this: [[1,2,3,4,5,6,7,8,9],[10,11,12,13,14,15],[16,17,18,19,20],[5,21,22],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]]
# where the first four elements in this listing are start nodes connecting to end nodes (of which there are 22 in this scratch map). We use this to count up the number of times they appear in a hash  in the
#raw_edge_appearances variable. In reality, everything done in this boils down to getting a set of data like that two dimensional array, where the actual elements correspond to some unique way to 
#map back which node it actually is, so that we can re-print the edges below in the csv
pageranks = pageRank(listing, alpha = 0.85, convergence=0.000000000000000000000001)
raw_edge_appearances = [item for sublist in listing for item in sublist]
degree_counts = Counter(raw_edge_appearances)
results = csv.writer(open(results_location, 'wb'), delimiter=',', quotechar='\"', quoting=csv.QUOTE_MINIMAL)
for edge in edges:
    results.writerow([str(edge.id), edge.start_node, edge.end_node, edge.time, edge.edge_id, edge.flagged, edge.style, edge.start_node_kind, edge.end_node_kind, edge.analysis_metadata_id, edge.curation_id, edge.graph_id, pageranks[nodes.index({'term':edge.start_node,'kind':edge.start_node_kind})], pageranks[nodes.index({'term':edge.end_node,'kind':edge.end_node_kind})], degree_counts[nodes.index({'term':edge.start_node,'kind':edge.start_node_kind})], degree_counts[nodes.index({'term':edge.end_node,'kind':edge.end_node_kind})]])

end = time.time()
print end - start

