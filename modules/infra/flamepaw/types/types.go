package types

type GithubWebhook struct {
	Ref     string `json:"ref"`
	BaseRef string `json:"base_ref,omitempty"`
	Action  string `json:"action"`
	Commits []struct {
		ID        string `json:"id"`
		Message   string `json:"message"`
		Timestamp string `json:"timestamp"`
		URL       string `json:"url"`
		Author    struct {
			Name     string `json:"name"`
			Email    string `json:"email"`
			Username string `json:"username"`
		} `json:"author"`
	}
	Repo struct {
		ID          int    `json:"id"`
		Name        string `json:"name"`
		FullName    string `json:"full_name"`
		Description string `json:"description"`
		URL         string `json:"url"`
		Owner       struct {
			Login            string `json:"login"`
			ID               int    `json:"id"`
			AvatarURL        string `json:"avatar_url"`
			URL              string `json:"url"`
			HTMLURL          string `json:"html_url"`
			OrganizationsURL string `json:"organizations_url"`
		} `json:"owner"`
		HTMLURL    string `json:"html_url"`
		CommitsURL string `json:"commits_url"`
	} `json:"repository"`
	Pusher struct {
		Name        string `json:"name"`
		Description string `json:"description"`
	} `json:"pusher,omitempty"`
	Sender struct {
		Login            string `json:"login"`
		ID               int    `json:"id"`
		AvatarURL        string `json:"avatar_url"`
		URL              string `json:"url"`
		HTMLURL          string `json:"html_url"`
		OrganizationsURL string `json:"organizations_url"`
	} `json:"sender,omitempty"`
	HeadCommit struct {
		ID      string `json:"id"`
		Message string `json:"message"`
		Author  struct {
			Name     string `json:"name"`
			Email    string `json:"email"`
			Username string `json:"username"`
		} `json:"author,omitempty"`
	} `json:"head_commit,omitempty"`
	PullRequest struct {
		ID      int    `json:"id"`
		Number  int    `json:"number"`
		State   string `json:"state"`
		Locked  bool   `json:"locked"`
		Title   string `json:"title"`
		Body    string `json:"body"`
		HTMLURL string `json:"html_url"`
		URL     string `json:"url"`
		User    struct {
			Login            string `json:"login"`
			ID               int    `json:"id"`
			AvatarURL        string `json:"avatar_url"`
			URL              string `json:"url"`
			HTMLURL          string `json:"html_url"`
			OrganizationsURL string `json:"organizations_url"`
		} `json:"user"`
		Base struct {
			Repo struct {
				ID          int    `json:"id"`
				Name        string `json:"name"`
				FullName    string `json:"full_name"`
				Description string `json:"description"`
				URL         string `json:"url"`
				Owner       struct {
					Login            string `json:"login"`
					ID               int    `json:"id"`
					AvatarURL        string `json:"avatar_url"`
					URL              string `json:"url"`
					HTMLURL          string `json:"html_url"`
					OrganizationsURL string `json:"organizations_url"`
				} `json:"owner"`
				HTMLURL    string `json:"html_url"`
				CommitsURL string `json:"commits_url"`
			} `json:"repo"`
			ID      int    `json:"id"`
			Number  int    `json:"number"`
			State   string `json:"state"`
			Title   string `json:"title"`
			Body    string `json:"body"`
			HTMLURL string `json:"html_url"`
			URL     string `json:"url"`
			Ref     string `json:"ref"`
			Label   string `json:"label"`
			User    struct {
				Login            string `json:"login"`
				ID               int    `json:"id"`
				AvatarURL        string `json:"avatar_url"`
				URL              string `json:"url"`
				HTMLURL          string `json:"html_url"`
				OrganizationsURL string `json:"organizations_url"`
			} `json:"user"`
			CommitsURL string `json:"commits_url"`
		} `json:"base"`
		Head struct {
			Repo struct {
				ID          int    `json:"id"`
				Name        string `json:"name"`
				FullName    string `json:"full_name"`
				Description string `json:"description"`
				URL         string `json:"url"`
				Owner       struct {
					Login            string `json:"login"`
					ID               int    `json:"id"`
					AvatarURL        string `json:"avatar_url"`
					URL              string `json:"url"`
					HTMLURL          string `json:"html_url"`
					OrganizationsURL string `json:"organizations_url"`
				} `json:"owner"`
				HTMLURL    string `json:"html_url"`
				CommitsURL string `json:"commits_url"`
			} `json:"repo"`
			ID      int    `json:"id"`
			Number  int    `json:"number"`
			State   string `json:"state"`
			Title   string `json:"title"`
			Body    string `json:"body"`
			HTMLURL string `json:"html_url"`
			URL     string `json:"url"`
			Ref     string `json:"ref"`
			Label   string `json:"label"`
			User    struct {
				Login            string `json:"login"`
				ID               int    `json:"id"`
				AvatarURL        string `json:"avatar_url"`
				URL              string `json:"url"`
				HTMLURL          string `json:"html_url"`
				OrganizationsURL string `json:"organizations_url"`
			} `json:"user"`
			CommitsURL string `json:"commits_url"`
		} `json:"head"`
	} `json:"pull_request,omitempty"`
	Issue struct {
		ID      int    `json:"id"`
		Number  int    `json:"number"`
		State   string `json:"state"`
		Title   string `json:"title"`
		Body    string `json:"body"`
		HTMLURL string `json:"html_url"`
		URL     string `json:"url"`
		User    struct {
			Login            string `json:"login"`
			ID               int    `json:"id"`
			AvatarURL        string `json:"avatar_url"`
			URL              string `json:"url"`
			HTMLURL          string `json:"html_url"`
			OrganizationsURL string `json:"organizations_url"`
		} `json:"user"`
	} `json:"issue,omitempty"`
}

type VAPID struct {
	Endpoint string `json:"endpoint"`
	Auth     string `json:"auth"`
	P256dh   string `json:"p256dh"`
	Data     string `json:"data"`
}

type APIResponse struct {
	Done    bool        `json:"done"`
	Reason  *string     `json:"reason"`
	Context interface{} `json:"context"`
}

type StaffRole struct {
	ID           string  `json:"id"`
	StaffID      string  `json:"staff_id"`
	Perm         float32 `json:"perm"`
	FriendlyName string  `json:"fname"`
}

type StaffRoles map[string]StaffRole

// Admin
type StaffPerms struct {
	IsStaff bool `json:"staff"`
	Perm    int  `json:"perm"`
}

// Implements a StateInterface for bots and servers
type BotState struct {
	Value       int
	Description string
}

// Only Int() is used
func (s BotState) Int() int {
	return s.Value
}

// Bot States (Only two needed for flamepaw)
var BotStateApproved = BotState{
	Value:       0,
	Description: "Approved",
}

var BotStateCertified = BotState{
	Value:       6,
	Description: "Certified",
}
