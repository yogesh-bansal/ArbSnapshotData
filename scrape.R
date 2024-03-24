## Load Helper Functions
source("helperfuncs.R")

########################################################
## Scrape Data
########################################################
prop_df <- get_proposals("arbitrumfoundation.eth")
prop_df$scores <- sapply(prop_df$scores,function(x) paste(x,collapse="<||>"))
prop_df$choices <- sapply(prop_df$choices,function(x) paste(x,collapse="<||>"))
saveRDS(prop_df,"Proposals.RDS")
# readr::write_csv(prop_df,"Proposals.csv")
vote_l <- list()
idx <- 1
while(TRUE)
{
	qry_res <- tryCatch(
	{
		get_votes(prop_df$id[idx])
	},
	error = function(err) err
	)
	if(inherits(qry_res, "error"))
	{
		message("Votes Error")
		Sys.sleep(2)
		next
	}
	vote_l[[idx]] <- qry_res
	message(paste0("Proposal:",idx,"/",nrow(prop_df)))
	idx <- idx + 1
	if(idx > nrow(prop_df)) break()
}
vote_df <- do.call(rbind,vote_l)
vote_df$choice <- sapply(vote_df$choice,function(x) paste(x,collapse="<||>"))
saveRDS(vote_df,"Votes.RDS")
# readr::write_csv(vote_df,"Votes.csv")
########################################################
########################################################