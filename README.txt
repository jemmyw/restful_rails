= RESTFUL-RAILS

http://github.com/jemmyw/restful_rails

** Currently under development, and not ideal for use in an actual project **

== DESCRIPTION:

In a restful application most controllers look the same or very similar. This plugin extends the
idea of resources_controller (http://blog.ardes.com/resources_controller) by removing the need to
actually have any controller files. Instead you provide an extended routing file and the
controllers are defined from there.

Example restful.rb file (placed in config):

    resource :tasks do
      allow

      resource :items do
        allow

        after :create do |format, success|
          format.html { redirect_to task_url(@item.task) } if success
        end
      end
    end

In the above example we get a tasks controller at /tasks for Task models with an items controller
at /tasks/items for Item models. The allow statements enable access to the controllers (denied by
default). The after create callback tells the items controller to redirect to the task show action
after an item has been created, instead of showing the item.

Jeremy Wells (jemmyw@gmail.com)

== LICENSE:

(The MIT License)

Copyright (c) 2008 Jeremy Wells <jemmyw@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
