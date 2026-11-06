<!-- 
Update the sample list provided below for your navigation bar. Each item should appear as a list item. Include the name of your markdown files, replacing the .md extension with .html. Leave {: .active} as is - this applies the active class to the list item on the current page, so the style outlined in style.css is applied.

Update the content as follows:
- [Your Menu Item Display Name]({{ '/nameofmarkdownfile.html' | relative_url }}){% if page.url == '/nameofmarkdownfile.html' %}{: .active}{% endif %}
-->

- [Home]({{ '/index.html' | relative_url }}){% if page.url == '/' or page.url == '/index.html' %}{: .active}{% endif %}
- [Lab 1]({{ '/lab1.html' | relative_url }}){% if page.url == '/lab1.html' %}{: .active}{% endif %}
- [Lab 2]({{ '/lab2.html' | relative_url }}){% if page.url == '/lab2.html' %}{: .active}{% endif %}