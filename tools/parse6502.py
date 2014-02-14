from pyquery import PyQuery
import re

alpha = re.compile("[a-zA-Z]")


with open("6502table.html") as input_file:
    p = PyQuery(input_file.read())
    for tr in p("table.wikitable tr"):
        tds = tr.findall("td")
        hx = "0x" + tds[0].text.strip()
        try: op = tds[1].find("span").find("a")
        except: continue
        if op is None: continue
        op = op.text.strip()
        md = tds[2].text.strip()
        if op:
            md = ''.join(alpha.findall(md))
            print "case " + hx + ": code=" + op + ";",
            if (md and md != "Absolute"): print "mode=" + md + ";",
            print
