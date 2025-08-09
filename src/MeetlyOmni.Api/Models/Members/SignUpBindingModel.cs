namespace MeetlyOmni.Api.Models.Members
{
    public class SignUpBindingModel
    {
        public string OrganizationName { get; set; }

        public string Email { get; set; }

        public string Password { get; set; }

        public string FullName { get; set; }

        public string PhoneNumber { get; set; }
    }
}
