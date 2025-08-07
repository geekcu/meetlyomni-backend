// <copyright file="RoleConstants.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Common.Constants
{
    public static class RoleConstants
    {
        /// <summary>
        /// 公司管理员角色
        /// </summary>
        public const string Admin = "admin";

        /// <summary>
        /// 公司员工角色
        /// </summary>
        public const string Employee = "employee";

        /// <summary>
        /// 获取所有系统角色
        /// </summary>
        public static readonly string[] AllRoles = { Admin, Employee };
    }
}

