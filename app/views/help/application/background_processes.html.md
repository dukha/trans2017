##Background Processes
<%=raw(render :partial => $APPLICATION_HELP_VIEW_DIR + "shared/horizontal_menu") %>
* Whenever there is a long running process(like upload or publish) developers will have ensured that this process runs in the background and does not stop anyone from using Vipassana Translator.
* As a user you will not see any erros if there are any: however an administrator will receive and email if thing go wrong and let you know.
> * Generally the process can be started again without a problem
* As a user you will see a message saying that your process has been placed on a queue
#####Under Construction...