## Load libraries
library(jsonlite)
library(httr)
library(lubridate)
library(ghql)
library(dplyr)

## Initialize Client Connection
con <- GraphqlClient$new("https://hub.snapshot.org/graphql?")

## Prepare New Query
qry <- Query$new()

## Add Proposals Query
qry$query('prop_data',
	'query prop_data($slugid: String!, $timestamp: Int!)
	{
		proposals(orderBy: "created", orderDirection: asc,first:1000,where:{space:$slugid,created_gt:$timestamp}) 
		{
			id
			space{id}
			ipfs
			author
			created
			network
			type
			title
			body
			start
			end
			state
			votes
			choices
			scores_state
			scores
		}
	}'
)

## Add Votes Query
qry$query('vote_data',
	'query vote_data($propid: String!, $timestamp: Int!)
	{
		votes(orderBy: "created", orderDirection: asc,first:1000,where:{proposal:$propid,created_gt:$timestamp}) 
		{
			id
			proposal{id}
			ipfs
			voter
			created
			choice
			vp
		}
	}'
)

########################################################
## Helper Funcs
########################################################
get_proposals <- function(slug)
{
    ## Loop historical
    c_timestamp <- 0
    prop_data <- data.frame()
    while(TRUE)
    {
        pd_t <- fromJSON(con$exec(qry$queries$prop_data,list(slugid = slug,timestamp=c_timestamp)))$data$proposals
        if(length(pd_t)==0) break()
        prop_data <- bind_rows(prop_data,pd_t)
        id_last <- tail(pd_t$id,1)
        c_timestamp <- as.numeric(tail(pd_t$created,1))
        message(paste0("Fetched ",nrow(prop_data)," Entries"))
        # Sys.sleep(1)
    }
    prop_data$space_id <- prop_data$space$id
    prop_data$space <- NULL
    return(prop_data)
}
get_votes <- function(prop)
{
    ## Loop historical
    c_timestamp <- 0
    vote_data <- data.frame()
    while(TRUE)
    {
        # Sys.sleep(1)
        vd_t <- fromJSON(con$exec(qry$queries$vote_data,list(propid = prop,timestamp=c_timestamp)))$data$votes
        if(length(vd_t)==0) break()
        vote_data <- bind_rows(vote_data,vd_t)
        id_last <- tail(vd_t$id,1)
        c_timestamp <- as.numeric(tail(vd_t$created,1))
        message(paste0("Fetched ",nrow(vote_data)," Entries"))
    }
    vote_data$prop_id <- vote_data$proposal$id
    vote_data$proposal <- NULL
    return(vote_data)
}
########################################################
########################################################