#!/usr/bin/env python
#
# Script that creates an HTML list of packages in our debian repository
#
# Repository path fixed to /var/packages
# HTML output on stdout

repos = ("stable", "staging", "dev")


import os, sys, gzip, time

# Build packages tree

packages = {}
for repo in repos:
  r_path = "/var/packages/" + repo

  distribs = [x for x in os.listdir(r_path + "/dists/") if os.path.isdir(r_path + "/dists/" + x)]
  for distrib in distribs:
    d_path = r_path + "/dists/" + distrib
    if distrib not in packages:
      packages[distrib] = {}

    components = [x for x in os.listdir(d_path) if os.path.isdir(d_path + "/" + x)]
    for component in components:
      c_path = d_path + "/" + component
      if component not in packages[distrib]:
        packages[distrib][component] = {}

      archs = [x.split("-",1)[1] for x in os.listdir(c_path) if x.startswith("binary-") and os.path.isdir(c_path + "/" + x)]
      for arch in archs:
	a_path = c_path + "/binary-" + arch

	packages_data = gzip.open(a_path + "/Packages.gz", 'rb').read()
        pname = pversion = None
	for line in packages_data.split("\n"):
          if not line and pname is not None:
	    if pname in packages[distrib][component]:
	      packages[distrib][component][pname]["versions"][repo] = pversion
	      packages[distrib][component][pname]["archs"][repo] = arch
	    else:
	      packages[distrib][component][pname] = {"versions": {repo: pversion}, "archs": {repo: arch}}
	  elif line.startswith("Package:"):
	    pname = line.split(" ",1)[1]
          elif line.startswith("Version:"):
	    pversion = line.split(" ",1)[1]


      if not packages[distrib][component]:
	del packages[distrib][component]

    if not packages[distrib]:
      del packages[distrib]


# Create HTML
html = """<html>
<head>
<title>Camptocamp Debian/Ubuntu package repositories</title>
<style  TYPE="text/css">
body { font-family:sans-serif; }
div.distrib { background-color: #aaf; padding: 10px; margin: 10px; }
div.component { background-color: #fff; padding: 10px; margin: 10px; }
th { text-align: left; }
th.p_name { width: 15em; }
th.p_version { width: 15em; }
</style>
</head>
<body>
<p>Repository pkg.camptocamp.net - updated on %s
""" %(time.strftime("%Y-%m-%d %H:%M:%S"))
for distrib in packages.keys():
  html += '<div class="distrib"><h2>%s</h2>\n' %(distrib)

  for component in packages[distrib].keys():
    html += '<div class="component"><h3>%s</h3>\n' %(component)

    html += '<table><tr><th class="p_name">Package</th><th class="p_version">Stable</th><th class="p_version">Staging</td><th class="p_version">Dev</td></tr>\n'

    packages_names = packages[distrib][component].keys()
    packages_names.sort()
    for package in packages_names:
      versions = packages[distrib][component][package]["versions"]
      for repo in repos:
        if repo not in versions:
          versions[repo] = "-"
      html += '<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>\n' %(package, versions["stable"], versions["staging"], versions["dev"])

    html += '</table>'

    html += '</div>'
  html += '</div>'

html += """</body>
</html>
"""

print html