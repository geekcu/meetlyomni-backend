
using System.Security.Claims;

using MeetlyOmni.Api.Data;
using MeetlyOmni.Api.Data.Entities;
using MeetlyOmni.Api.Models.Members;

using Microsoft.AspNetCore.Identity;

namespace MeetlyOmni.Api.Service.MemberService
{
    public class MemberService : IMemberService
    {
        private const string AdminRoleName = "Admin";
        private readonly UserManager<Member> _userManager;


        public MemberService(UserManager<Member> userManager)
        {
            _userManager = userManager;

        }

        public async Task<Member> CreateAdminAsync(Guid orgId, string email, string password, string phone, string fullName)
        {
            var member = new Member
            {
                Id = Guid.NewGuid(),
                OrgId = orgId,
                Email = email.Trim(),
                UserName = email.Trim(),
                PhoneNumber = phone,
                CreatedAt = DateTimeOffset.UtcNow,
                UpdatedAt = DateTimeOffset.UtcNow
            };

            var createResult = await _userManager.CreateAsync(member, password);

            if (!createResult.Succeeded)
            {
                throw new InvalidOperationException(string.Join("; ", createResult.Errors.Select(e => $"{e.Code}:{e.Description}")));
            }

            await _userManager.AddClaimAsync(member, new Claim("full_name", fullName));


            var addRole = await _userManager.AddToRoleAsync(member, AdminRoleName);
            if (!addRole.Succeeded)
            {
                throw new InvalidOperationException(string.Join("; ", addRole.Errors.Select(e => $"{e.Code}:{e.Description}")));
            }

            return member;
        }
    }
}
