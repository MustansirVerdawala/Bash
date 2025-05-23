# crystal-calendar.widget by locupleto
#
# https://github.com/locupleto/crystal-widgets
#
# Based on calendar by felixHageloh
# https://github.com/felixhageloh/uebersicht-widgets/

sundayFirstCalendar = 'cal -h && date "+%-m %-d %y"'

mondayFirstCalendar =  'cal -h | awk \'{ print " "$0; getline; print "Mo Tu We Th Fr Sa Su"; \
getline; if (substr($0,1,2) == " 1") print "                    1 "; \
do { prevline=$0; if (getline == 0) exit; print " " \
substr(prevline,4,17) " " substr($0,1,2) " "; } while (1) }\' && date "+%-m %-d %y"'

# figure out if user wants Monday or Sunday as the first day of the week
command: "crystal-calendar.widget/widget_runner.sh"

# Set this to true to enable previous and next month dates, or false to disable
otherMonths: true

# Check for new date, once every minute
refreshFrequency: 60000

style: """
display: block;
border-radius: 5px;
top: 15px;/*220px;*/
left: 212px;
background: rgba(255, 255, 255, .1);
color: #fff;
font-family: Helvetica Neue;
width: 178px;
height: 190px;
padding: 5px; /* Adjust padding to center the content */

table {
  border-collapse: collapse;
  table-layout: fixed;
  width: 100%; /* Make table use full width of the container */
  height: 100%; /* Make table use full height of the container */
  margin: auto; /* Center the table */
}

td {
  text-align: center;
  padding: 4px 4px;
  text-shadow: 0 0 1px rgba(#000, 0.5);
}

thead tr {
  &:first-child td {
    font-size: 23px;
    font-weight: 100;
  }

  &:last-child td {
    font-size: 11px;
    padding-bottom: 12px;
    font-weight: 500;
  }
}

tbody td {
  font-size: 12px;
}

.today {
  font-weight: bold;
  background: rgba(#fff, 0.2);
  border-radius: 50%;
}

.grey {
  color: rgba(#C0C0C0, .7);
}

"""

render: -> """
  <table>
    <thead>
    </thead>
    <tbody>
    </tbody>
  </table>
"""


updateHeader: (rows, table) ->
  thead = table.find("thead")
  thead.empty()

  thead.append "<tr><td colspan='7'>#{rows[0]}</td></tr>"
  tableRow = $("<tr></tr>").appendTo(thead)
  daysOfWeek = rows[1].split(/\s+/)

  for dayOfWeek in daysOfWeek
    tableRow.append "<td>#{dayOfWeek}</td>"

updateBody: (rows, table) ->
  #Set to 1 to enable previous and next month dates, 0 to disable
  PrevAndNext = 1

  tbody = table.find("tbody")
  tbody.empty()

  rows.splice 0, 2
  rows.pop()

  today = rows.pop().split(/\s+/)
  month = today[0]
  date = today[1]
  year = today[2]

  lengths = [31, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30]
  if year%4 == 0
    lengths[2] = 29

  for week, i in rows
    days = week.split(/\s+/).filter((day) -> day.length > 0)
    tableRow = $("<tr></tr>").appendTo(tbody)

    if i == 0 and days.length < 7
      for j in [days.length...7]
        if @otherMonths == true
          k = 6 - j
          cell = $("<td>#{lengths[month-1]-k}</td>").appendTo(tableRow)
          cell.addClass("grey")
        else
          cell = $("<td></td>").appendTo(tableRow)

    for day in days
      day = day.replace(/\D/g, '')
      cell = $("<td>#{day}</td>").appendTo(tableRow)
      cell.addClass("today") if day == date

    if i != 0 and 0 < days.length < 7 and @otherMonths == true
      for j in [1..7-days.length]
        cell = $("<td>#{j}</td>").appendTo(tableRow)
        cell.addClass("grey")

update: (output, domEl) ->
  rows = output.split("\n")
  table = $(domEl).find("table")

  @updateHeader rows, table
  @updateBody rows, table
