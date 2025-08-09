using MeetlyOmni.Api.Data;
using MeetlyOmni.Api.Models.Members;
using MeetlyOmni.Api.Service.MemberService;
using MeetlyOmni.Api.Service.OrganizationService;

namespace MeetlyOmni.Api.Service.RegistrationService
{
    public class RegistrationService : IRegistrationService
    {
        private readonly ApplicationDbContext _context;
        private readonly IOrganizationService _orgService;
        private readonly IMemberService _memberService;

        public RegistrationService(ApplicationDbContext context, IOrganizationService orgService, IMemberService memberService)
        {
            _context = context;
            _orgService = orgService;
            _memberService = memberService;
        }
        public async Task<MemberDto> SignUpAdminAsync(SignUpBindingModel input)
        {


            var org = await _orgService.CreateOrganizationAsync(input.OrganizationName);
            var member = await _memberService.CreateAdminAsync(org.OrgId, input.Email, input.Password, input.PhoneNumber, input.FullName);


            return new MemberDto
            {
                Id = member.Id,
                OrganizationId = org.OrgId,
                OrganizationCode = org.OrganizationCode,
                Email = member.Email!,
                FullName = input.FullName,
                PhoneNumber = member.PhoneNumber,
                Role = "Admin"
            };
        }
    }
}
