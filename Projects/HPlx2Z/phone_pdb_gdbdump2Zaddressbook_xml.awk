# phone_pdb_gdbdump2Zaddressbook_xml.awk 
#   		HP200LX Phone Db to AddressBook Xml
#   Author: Howard Abbey
#     Date: Apr. 4, 2002
# Language: Awk, specifically mawk under Linux 
#  Purpose: To export HP 200LX Phone database file to the Addressbook 
#           format used on the Zaurus.  Input is to be the output of 
#           gdbdump phone.pdb.  Output hopefully will be acceptable 
#           to Qtopia's addressbook.
#    Usage: gdbdump -ns /Archive/hpbakup/data/phone.pdb |\
#           mawk -f phone_pdb_gdbdump2Zaddressbook_xml.awk \
#           > newfile.addressbook.xml
#           manually merge newfile with existing addressbook.xml
#
# Program released to the public domain.
#
####
#   Todo: 
# find most convienent and safe way to auto-merge with existing addressbook 
#  - should wait until approved means to interface with Zaurus PIM apps.
# double check format is correct
# search input files for possible trouble makers, such as a "," in a data field
# Give to the world
# Parse name into parts 
# implement rid,  rinfo, and Uid fields
# find way to handle categories
# find and eliminate bugs
# guess gender based on name
#
#
####
function init_vars() {
  name = ""
  business = ""
  home = ""
  alternate = ""
  fax = ""
  title = ""
  category = ""
  company = ""
  address1 = ""
  address2 = ""
  city = ""
  state = ""
  zip = ""
  note = ""
}

# use BEGIN clause to setup program vars
BEGIN {

  init_vars()

#  FS=","
  FS="\",\""
  OFS=" "
}


# Input should be:
# "Name","Business",Home","Alternate","Fax","Title","Category","Company","Address1","Address2","City","State","Zip","Note"


{ 
  # Read in values  
  name = $1
  business = $2
  home = $3
  # I stored e-mail addresses in the alternate field
  alternate = $4
  fax = $5
  title = $6
  category = $7 
  company = $8
  address1 = $9
  address2 = $10
  city = $11
  state = $12
  zip = $13
  note = $14

  ##Fields requiring processing
  
  # Need to strip all of any beginning and ending quotes.
  # should only be in Name and note, because at beginning and end of line.
  # Drop first character of name (a double quote)
  name = substr(name,2)
  # Drop last character of note (a double quote)
  note = substr(note,0,length(note)) 

  # Notes:
  # Convert newline markers (\r\n) to newlines
  gsub(/\\r\\n/,"\n",note)
  # Add anything can't deal with to the start of the Note field
  #  Category difficult to convert.
  if ( category ) \
  {  
    notesOut = "Category: " category "\n---\n" note
  }
  else
  {
    notesOut = note
  }
  # Also, add a note that need to check result
  notesOut = notesOut "\n::::: Converted from HP Phone Db:::::"

  # Start constructing output:
  rec = "<Contact LastName=\"" name "\" FileAs=\"" name  "\" " 
  if ( business ) rec = rec "BusinessPhone=\"" business  "\" " 
  if ( home ) rec = rec "HomePhone=\"" home  "\" " 
  if ( alternate ) rec = rec "DefaultEmail=\"" alternate \
                                 "\" Emails=\"" alternate  "\" " 
  if ( fax ) rec = rec "BusinessFax=\"" fax  "\" " 
  if ( title ) rec = rec "JobTitle=\"" title  "\" " 
  if ( company ) rec = rec "Company=\"" company  "\" " 


  # Placement of address items depend on contents of company
  #  if company doesn't exist... 
  if ( ! company ) \
  {
     #Guess address is for Home
     if ( address1 || address2  ) rec = rec "HomeStreet=\"" 
     if ( address1 ) rec = rec address1 
     if ( address2 ) rec = rec " ; " address2 
     if ( address1 || address2  ) rec = rec "\" "
     if ( city ) rec = rec "HomeCity=\"" city  "\" " 
     if ( state ) rec = rec "HomeState=\"" state  "\" " 
     if ( zip ) rec = rec "HomeZip=\"" zip  "\" " 

  }
  else
  {
     #Guess address is for Business
     if ( address1 || address2  ) rec = rec "BusinessStreet=\"" 
     if ( address1 ) rec = rec address1 
     if ( address2 ) rec = rec " ; " address2  
     if ( address1 || address2  ) rec = rec "\" "
     if ( city ) rec = rec "BusinessCity=\"" city  "\" " 
     if ( state ) rec = rec "BusinessState=\"" state  "\" " 
     if ( zip ) rec = rec "BusinessZip=\"" zip  "\" "\

  } 

  if ( notesOut ) rec = rec "Notes=\"" notesOut  "\" " 
  rec = rec " />" 

  print rec
  init_vars()
}

###


