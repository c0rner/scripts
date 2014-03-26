# CSV to JSON posix compatible shell function
# Input: [Field separator] [Column headers]
#
# Global variable 'QUOTEDCSV' can be set as:
#   'NO': All values will be quoted (DEFAULT)
#   'YES': Values allready quoted correctly and inserted "as is"
#   'GUESS': Try guessing if quotation needed (very simplistic)
csv2json() {
   typeset -i count=0
   IFS="${1:-,}"
   headers="$2"

   if [ -z "${headers}" ]; then
   # Read headers from first line unless already set
      read headers
   fi

   # Count the number of header columns
   for name in ${headers}; do
      [ -z ${name} ] && break
      count=$((count + 1))
   done
   numheaders=${count}

   # Begin printing JSON formatted output
   echo "{"
   while read line; do
      echo -n "{"
      count=1
      set -- $headers
      for value in ${line}; do
         if [ "x${QUOTEDCSV^^}" = "xGUESS" ]; then
            # Try guessing if the value should be quoted or not
            [ ${value^^} != ${value,,} ] && value="\"${value}\""
         else
            [ "x${QUOTEDCSV^^}" != "xYES" ] && value="\"${value}\""
         fi

         echo -n "\"${1}\": ${value}, "
         shift

         # Stop if there are no more column headers
         count=$((count + 1))
         [ ${count} -gt ${numheaders} ] && break
      done
      echo "},"
   done
   echo "}"
}
