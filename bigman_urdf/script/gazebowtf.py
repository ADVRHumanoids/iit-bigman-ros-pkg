'''
Simple script to work around the bugs in gzsdf. Notice that there are no error checks,
and that the script expects a newline between the <wtf> tag and its children (see bigman.gazebo.wtf for an example)
Also, there can be only one level of wtf_cond (they can not be nested), and wtf_cond at the moment needs to be nested inside a wtf tag
The conditions in wtf_cond and in wtf tags under the if and unless attributes are checked by looking at environment variables.
If a variable is not set, we assume FALSE as a default
'''

from bs4 import BeautifulSoup
import sys
import string
import os

def a2b(v):
  if isinstance(v,bool):
    return v
  else:
    return v.lower() in ("yes", "true", "t", "1")

if __name__ == '__main__':
  wtf_file = open(sys.argv[1])
  soup_wtf = BeautifulSoup(wtf_file,"xml")
  sdf_file = open(soup_wtf.robot['filename'])
  soup_sdf = BeautifulSoup(sdf_file,"xml")
  bigman_config_file = open(sys.argv[2])
  soup_bigman_config = BeautifulSoup(bigman_config_file,"xml")

  try:
    for config_el in soup_bigman_config.find_all('property'):
      if(config_el.has_attr('name') and config_el.has_attr('value')):
        os.putenv(config_el['name'],config_el['value'])
        os.environ[config_el['name']] = config_el['value']

    for wtf_el in soup_wtf.find_all('wtf'):
      if (not wtf_el.has_attr('if') and not wtf_el.has_attr('unless')) or (wtf_el.has_attr('if') and a2b(os.getenv(wtf_el['if'], False)) or ((wtf_el.has_attr('unless') and not a2b(os.getenv(wtf_el['unless'], False))))):
        for wtf_cond_el in wtf_el.find_all('wtf_cond'):
          if (wtf_cond_el.has_attr('if') and a2b(os.getenv(wtf_cond_el['if'], False))) or (wtf_cond_el.has_attr('unless') and not a2b(os.getenv(wtf_cond_el['unless'], False))):
            wtf_cond_el.unwrap()
          else:
            wtf_cond_el.decompose()
          soup_el = soup_sdf.find(attrs={"name": wtf_el['reference']})
          if soup_el:
            soup_el.append(wtf_el.contents[1])
  finally:
    print(soup_sdf.prettify(formatter="minimal"))

