import { exec } from "child_process";
import fs from "fs";
import yaml from "js-yaml";

interface ResumeTemplate {
  personal: any[];
  work: any[];
  education: any[];
  affiliations: any[];
  awards: any[];
  certificates: any[];
  publications: any[];
  talks: any[];
  schools: any[];
  teaching: any[];
  projects: Project[];
  skills: any[];
  languages: any[];
  interests: any[];
  references: any[];
}

interface Project {
  name: string;
  url: string;
  github: string;
  "github-stars": number;
  startDate: Date;
  endDate: Date | null;
  highlights: string[];
}

const TEMPLATE_PATH = "./template/template.yml";

const getGitHubStars = (repo: string): Promise<number> => {
  return new Promise((resolve, reject) => {
    let command: string;

    if (process.env.SHELL) {
      // bash
      // https://gist.github.com/jasonrudolph/6057563?permalink_comment_id=4150026#gistcomment-4150026
      command = `curl -s https://api.github.com/repos/${repo} | grep stargazers_count | cut -d : -f 2 | tr -d " " | tr -d ","`;
    } else if (process.env.ComSpec || process.env.PSModulePath) {
      // cmd
      command = `curl -s https://api.github.com/repos/${repo} | findstr "stargazers_count" | for /f "tokens=2 delims=:" %A in ('findstr "stargazers_count"') do @echo %A`;
    } else {
      return reject(new Error("Unknown shell environment"));
    }

    exec(command, (err, stdout) => {
      if (err) {
        reject(err);
        return;
      }
      resolve(parseInt(stdout.trim().replace(",", "")));
    });
  });
};

const compileTypst = () => {
  console.log("Compiling template.typ to template.pdf");

  const compileCmd = "typst compile template/template.typ template/template.pdf --root ./";
  exec(compileCmd, (err, stdout) => {
    if (err) {
      console.error(err);
      return;
    }
    console.log(stdout);
    console.log("Compiled template.typ to template.pdf successfully!");
  });
};

const updateProjectsYaml = async () => {
  const projectsYaml = fs.readFileSync(TEMPLATE_PATH, "utf8");
  const yamlContent = yaml.load(projectsYaml) as ResumeTemplate;

  let hasChanges = false;

  for (const project of yamlContent.projects) {
    if (project.github) {
      const repoPath = project.github.split("/").slice(-2).join("/");
      console.log(`Fetching stars for ${project.name} (${repoPath})`);
      try {
        const oldStars = project["github-stars"];
        project["github-stars"] = await getGitHubStars(repoPath);
        if (project["github-stars"] !== oldStars) {
          hasChanges = true;
          console.log(`Updated stars for ${project.name}: ${oldStars} -> ${project["github-stars"]}`);
        }
      } catch (error) {
        console.error(`Failed to get stars for ${project.name}:`, error);
      }
    }
  }

  if (!hasChanges) {
    console.log("No changes detected, files will not be updated");
    return;
  }

  const updatedYaml = yaml.dump(yamlContent, { quotingType: '"' });
  fs.writeFileSync(TEMPLATE_PATH, updatedYaml, "utf8");
  console.log("Updated template.yml successfully!");

  compileTypst();
};

updateProjectsYaml().catch(console.error);
